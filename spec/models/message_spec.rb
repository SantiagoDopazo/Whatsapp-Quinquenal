require "rails_helper"

RSpec.describe Message, type: :model do
  let_it_be(:conversation, refind: true) { create(:conversation, last_activity_at: nil) }
  let_it_be(:operator) { create(:agent, company: conversation.company) }
  let_it_be(:foreign_number) { create(:phone_number) }
  let(:inbound) { build(:message, conversation: conversation) }
  let(:outbound) { build(:message, :outbound, conversation: conversation) }
  let(:message_time) { Time.zone.parse("2026-10-30 10:00:00") }

  it "records inbound text and its provider ID" do
    inbound.save!
    expect(inbound.reload.status).to eq("received")
    expect(inbound.agent).to be_nil
    expect(inbound.phone_number).to eq(conversation.phone_number)
  end

  it "queues outbound text with an author and stable client request ID" do
    outbound.save!
    expect(outbound.reload.status).to eq("queued")
    expect(outbound.client_request_id).to be_present
    expect(outbound.external_id).to be_nil
    expect(outbound.agent).to be_present
  end

  it "requires text content and an inbound provider ID" do
    inbound.body = " "
    inbound.external_id = nil
    expect(inbound).not_to be_valid
    expect(inbound.errors[:body]).to be_present
    expect(inbound.errors[:external_id]).to be_present
  end

  it "represents an unsupported inbound message without inventing text" do
    inbound.message_type = :unsupported
    inbound.body = nil
    expect(inbound.save).to be(true)
    outbound.message_type = :unsupported
    expect(outbound).not_to be_valid
  end

  it "does not allow messages on legacy conversations without a line" do
    conversation.update_columns(phone_number_id: nil)
    expect(build(:message, conversation: conversation)).not_to be_valid
  end

  it "does not allow mismatched conversation and number even through SQL writes" do
    inbound.phone_number = foreign_number
    expect(inbound).not_to be_valid
    expect { inbound.save!(validate: false) }.to raise_error(ActiveRecord::InvalidForeignKey)
  end

  it "requires an outbound author authorized on the number" do
    outbound.agent = operator
    expect(outbound).not_to be_valid
    PhoneNumberAccess.create!(agent: operator, phone_number: conversation.phone_number)
    expect(outbound).to be_valid
    outbound.agent = nil
    expect(outbound).not_to be_valid
  end

  it "rejects an author from another company" do
    outbound.agent = create(:agent, company: foreign_number.company, role: "admin")
    expect(outbound).not_to be_valid
    inbound.agent = operator
    expect(inbound).not_to be_valid
  end

  context "with a stored inbound message" do
    let_it_be(:stored, refind: true) { create(:message, conversation: conversation) }
    let(:duplicate) { build(:message, conversation: conversation, external_id: stored.external_id) }
    let(:other_contact) { create(:contact, company: foreign_number.company) }
    let(:other_conversation) { create(:conversation, phone_number: foreign_number, contact: other_contact) }

    it "deduplicates the external ID at model and database level" do
      expect(duplicate).not_to be_valid
      expect { duplicate.save!(validate: false) }.to raise_error(ActiveRecord::RecordNotUnique)
    end

    it "allows an identical external ID on another line" do
      expect(create(:message, external_id: stored.external_id, conversation: other_conversation)).to be_persisted
    end

    it "preserves the content and source identity" do
      expect(stored.update(body: "Changed")).to be(false)
      expect(stored.reload.update(external_id: "changed-id")).to be(false)
      expect(stored.reload.update(conversation: create(:conversation))).to be(false)
    end

    it "prevents deleting a conversation with messages" do
      expect(conversation.destroy).to be(false)
      expect(stored.reload).to be_persisted
    end
  end

  context "with an outbound message" do
    let_it_be(:sent, refind: true) { create(:message, :outbound, conversation: conversation) }
    let(:duplicate) { build(:message, :outbound, conversation: conversation, client_request_id: sent.client_request_id) }

    it "deduplicates client requests at database level" do
      expect(duplicate).not_to be_valid
      expect { duplicate.save!(validate: false) }.to raise_error(ActiveRecord::RecordNotUnique)
    end

    it "advances delivery and ignores duplicated or older states" do
      sent.record_status!(:accepted, at: Time.current, external_id: "provider-sent")
      sent.record_status!(:read, at: Time.current)
      expect(sent.record_status!(:sent, at: 1.hour.ago)).to be(false)
      expect(sent.record_status!(:read, at: Time.current)).to be(false)
      expect(sent.reload.status).to eq("read")
      expect(sent.update(status: :queued)).to be(false)
    end

    it "requires an external ID before reporting provider acceptance" do
      expect { sent.record_status!(:accepted, at: Time.current) }.to raise_error(ActiveRecord::RecordInvalid)
      expect(sent.reload.status).to eq("queued")
    end

    it "preserves monotonic status timestamps when events are delayed" do
      sent.record_status!(:accepted, at: sent.status_at - 1.hour, external_id: "delayed")
      expect(sent.reload.status_at).to eq(sent.occurred_at)
      expect(sent.update(status_at: sent.status_at - 1.hour)).to be(false)
    end

    it "keeps uncertain outcomes without requeuing and allows later reconciliation" do
      sent.record_status!(:sending, at: Time.current)
      sent.record_status!(:unknown, at: Time.current)
      expect(sent.update(status: :queued)).to be(false)
      sent.reload.record_status!(:delivered, at: Time.current, external_id: "reconciled")
      expect(sent.reload.status).to eq("delivered")
    end

    it "does not regress a delivered message into failed" do
      sent.record_status!(:delivered, at: Time.current, external_id: "delivered")
      expect { sent.record_status!(:failed, at: Time.current) }.to raise_error(ActiveRecord::RecordInvalid)
      expect(sent.reload.status).to eq("delivered")
    end

    it "retains the message when its author is removed" do
      sent.agent.destroy!
      expect(sent.reload.agent).to be_nil
      expect(sent.update(status: :sending)).to be(true)
    end
  end

  it "advances conversation activity atomically without moving backwards for old events" do
    create(:message, conversation: conversation, occurred_at: message_time)
    create(:message, conversation: conversation, occurred_at: message_time - 1.hour)
    expect(conversation.reload.last_activity_at).to eq(message_time)
    create(:message, conversation: conversation, occurred_at: message_time + 1.hour)
    expect(conversation.reload.last_activity_at).to eq(message_time + 1.hour)
  end

  it "rolls back activity when message creation rolls back" do
    described_class.transaction do
      inbound.save!
      raise ActiveRecord::Rollback
    end
    expect(conversation.reload.last_activity_at).to be_nil
  end

  it "limits messages by company and authorized line" do
    inbound.save!
    expect(CompanyAccess.new(operator).messages).to be_empty
    PhoneNumberAccess.create!(agent: operator, phone_number: conversation.phone_number)
    expect(CompanyAccess.new(operator).messages).to contain_exactly(inbound)
    expect(CompanyAccess.new(nil).messages).to be_empty
  end
end
