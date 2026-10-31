require "rails_helper"

RSpec.describe "Company data scope", type: :model do
  let_it_be(:company) { create(:company) }
  let_it_be(:other_company) { create(:company) }
  let_it_be(:operator) { create(:agent, company: company) }
  let_it_be(:coworker) { create(:agent, company: company) }
  let_it_be(:foreign_agent) { create(:agent, company: other_company) }
  let_it_be(:contact) { create(:contact, company: company) }
  let_it_be(:foreign_contact) { create(:contact, company: other_company) }
  let_it_be(:conversation) { create(:conversation, contact: contact) }
  let_it_be(:foreign_conversation) { create(:conversation, contact: foreign_contact) }

  it "shares contacts, agents and conversations between company operators" do
    expect(operator.company.agents).to contain_exactly(operator, coworker)
    expect(operator.company.contacts).to contain_exactly(contact)
    expect(operator.company.conversations).to contain_exactly(conversation)
    expect(coworker.company.conversations).to contain_exactly(conversation)
  end

  it "cannot retrieve another company's records by ID" do
    expect { operator.company.agents.find(foreign_agent.id) }.to raise_error(ActiveRecord::RecordNotFound)
    expect { operator.company.contacts.find(foreign_contact.id) }.to raise_error(ActiveRecord::RecordNotFound)
    expect { operator.company.conversations.find(foreign_conversation.id) }.to raise_error(ActiveRecord::RecordNotFound)
  end
end
