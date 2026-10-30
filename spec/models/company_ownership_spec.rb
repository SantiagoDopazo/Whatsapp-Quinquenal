require "rails_helper"

RSpec.describe "Company ownership", type: :model do
  it "allows the same WhatsApp contact in two companies" do
    contact = create(:contact)
    other = create(:contact, whatsapp_id: contact.whatsapp_id)

    expect(other.company).not_to eq(contact.company)
  end

  it "rejects a duplicate contact inside a company even without validations" do
    contact = create(:contact)
    duplicate = build(:contact, company: contact.company, whatsapp_id: contact.whatsapp_id)

    expect { duplicate.save!(validate: false) }.to raise_error(ActiveRecord::RecordNotUnique)
  end

  it "requires an explicit company for contacts and agents" do
    expect(build(:contact, company: nil)).not_to be_valid
    expect(build(:agent, company: nil)).not_to be_valid
  end

  it "rejects assignment to an agent of another company" do
    conversation = build(:conversation, agent: create(:agent))

    expect(conversation).not_to be_valid
    expect(conversation.errors[:agent]).to be_present
  end

  it "allows assignment inside the contact's company" do
    contact = create(:contact)
    conversation = build(:conversation, contact: contact, agent: create(:agent, company: contact.company))

    expect(conversation).to be_valid
  end

  it "does not move an existing contact or agent to another company" do
    company = create(:company)

    [ create(:contact), create(:agent) ].each do |record|
      expect(record.update(company: company)).to be(false)
      expect(record.reload.company).not_to eq(company)
    end
  end
end
