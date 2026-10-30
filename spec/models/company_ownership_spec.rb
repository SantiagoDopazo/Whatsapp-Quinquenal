require "rails_helper"

RSpec.describe "Company ownership", type: :model do
  let_it_be(:company) { create(:company) }
  let_it_be(:other_company) { create(:company) }
  let_it_be(:contact, refind: true) { create(:contact, company: company) }
  let_it_be(:agent, refind: true) { create(:agent, company: company) }
  let(:other_contact) { build(:contact, company: other_company, whatsapp_id: contact.whatsapp_id) }
  let(:duplicate_contact) { build(:contact, company: company, whatsapp_id: contact.whatsapp_id) }
  let(:contact_without_company) { build(:contact, company: nil) }
  let(:agent_without_company) { build(:agent, company: nil) }
  let(:cross_company_conversation) { build(:conversation, contact: other_contact, agent: agent) }
  let(:conversation) { build(:conversation, contact: contact, agent: agent) }

  it "allows the same WhatsApp contact in two companies" do
    expect(other_contact.save).to be(true)
    expect(other_contact.company).not_to eq(contact.company)
  end

  it "rejects a duplicate contact inside a company even without validations" do
    expect { duplicate_contact.save!(validate: false) }.to raise_error(ActiveRecord::RecordNotUnique)
  end

  it "requires an explicit company for contacts and agents" do
    expect(contact_without_company).not_to be_valid
    expect(agent_without_company).not_to be_valid
  end

  it "rejects assignment to an agent of another company" do
    expect(cross_company_conversation).not_to be_valid
    expect(cross_company_conversation.errors[:agent]).to be_present
  end

  it "allows assignment inside the contact's company" do
    expect(conversation).to be_valid
  end

  it "does not move an existing contact to another company" do
    expect(contact.update(company: other_company)).to be(false)
    expect(contact.reload.company).to eq(company)
  end

  it "does not move an existing agent to another company" do
    expect(agent.update(company: other_company)).to be(false)
    expect(agent.reload.company).to eq(company)
  end
end
