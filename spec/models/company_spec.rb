require "rails_helper"

RSpec.describe Company, type: :model do
  let(:company_without_name) { build(:company, name: " ") }

  it "requires a name" do
    expect(company_without_name).not_to be_valid
  end

  context "with contacts" do
    let_it_be(:contact, refind: true) { create(:contact) }

    it "does not delete the company" do
      expect(contact.company.destroy).to be(false)
      expect(contact.reload).to be_persisted
    end
  end

  context "with agents" do
    let_it_be(:agent, refind: true) { create(:agent) }

    it "does not delete the company" do
      expect(agent.company.destroy).to be(false)
      expect(agent.reload).to be_persisted
    end
  end

  context "with conversations in different companies" do
    let_it_be(:conversation) { create(:conversation) }
    let_it_be(:other_conversation) { create(:conversation) }

    it "returns only conversations belonging to its contacts" do
      expect(conversation.company.conversations).to contain_exactly(conversation)
    end
  end
end
