require "rails_helper"

RSpec.describe "WhatsApp lines", type: :model do
  let_it_be(:company) { create(:company) }
  let_it_be(:admin, refind: true) { create(:agent, company: company, role: "admin") }
  let_it_be(:operator, refind: true) { create(:agent, company: company) }
  let_it_be(:number, refind: true) { create(:phone_number, company: company) }
  let_it_be(:second_number) { create(:phone_number, company: company) }
  let_it_be(:foreign_number) { create(:phone_number) }
  let_it_be(:contact) { create(:contact, company: company) }
  let_it_be(:conversation, refind: true) { create(:conversation, contact: contact, phone_number: number) }
  let(:duplicate) { build(:conversation, contact: contact, phone_number: number) }

  it "keeps independent chats for the same customer on two lines" do
    expect {
      create(:conversation, contact: contact, phone_number: second_number)
    }.to change(Conversation, :count).by(1)
    expect(contact.conversations.distinct.pluck(:phone_number_id)).to contain_exactly(number.id, second_number.id)
  end

  it "rejects a second active chat on the same line in the model and database" do
    expect(duplicate).not_to be_valid
    expect { duplicate.save!(validate: false) }.to raise_error(ActiveRecord::RecordNotUnique)
  end

  it "allows a new chat after closing the previous one, but prevents reopening a duplicate" do
    conversation.closed!
    duplicate.save!
    expect(conversation.update(status: :open)).to be(false)
  end

  it "requires a line when creating or updating a conversation" do
    expect(build(:conversation, contact: contact, phone_number: nil)).not_to be_valid
    expect(conversation.update(phone_number: nil)).to be(false)
  end

  it "rejects contacts and agents from a different company" do
    expect(build(:conversation, contact: contact, phone_number: foreign_number)).not_to be_valid
    expect(conversation.update(agent: create(:agent, company: foreign_number.company))).to be(false)
  end

  it "allows every operator to see all company lines and conversations" do
    expect(operator.company.phone_numbers).to contain_exactly(number, second_number)
    expect(operator.company.conversations).to contain_exactly(conversation)
    expect(conversation.update(agent: operator)).to be(true)
    expect { operator.company.phone_numbers.find(foreign_number.id) }.to raise_error(ActiveRecord::RecordNotFound)
  end

  it "gives administrators the same company scope" do
    expect(admin.company.phone_numbers).to contain_exactly(number, second_number)
    expect(admin.company.conversations).to contain_exactly(conversation)
  end

  it "does not move a number to another account or move a conversation to another number" do
    expect(number.update(whatsapp_account: second_number.whatsapp_account)).to be(false)
    expect(conversation.update(phone_number: second_number)).to be(false)
    expect(conversation.update(phone_number: nil)).to be(false)
  end

  it "does not change a conversation's contact" do
    expect(conversation.update(contact: create(:contact, company: company))).to be(false)
    expect(conversation.errors[:contact]).to include("cannot be changed")
  end

  it "does not move a provider account between companies" do
    expect(number.whatsapp_account.update(company: foreign_number.company)).to be(false)
  end

  it "restricts deleting a line or account containing conversations" do
    expect(number.destroy).to be(false)
    expect(number.whatsapp_account.destroy).to be(false)
  end

  it "rejects duplicate external routing IDs" do
    expect(build(:phone_number, external_id: number.external_id)).not_to be_valid
    expect(build(:whatsapp_account, external_id: number.whatsapp_account.external_id)).not_to be_valid
  end

  it "rejects unknown connection states in the database" do
    expect { number.update_columns(status: "unknown") }.to raise_error(ActiveRecord::StatementInvalid)
  end
end
