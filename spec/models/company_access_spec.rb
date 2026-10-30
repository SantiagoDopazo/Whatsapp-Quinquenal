require "rails_helper"

RSpec.describe CompanyAccess do
  let_it_be(:company) { create(:company) }
  let_it_be(:other_company) { create(:company) }
  let_it_be(:agent) { create(:agent, company: company) }
  let_it_be(:other_agent) { create(:agent, company: other_company) }
  let_it_be(:contact) { create(:contact, company: company) }
  let_it_be(:other_contact) { create(:contact, company: other_company) }
  let_it_be(:account) { create(:whatsapp_account, company: company) }
  let_it_be(:other_account) { create(:whatsapp_account, company: other_company) }
  let(:access) { described_class.new(agent) }

  it "limits companies to the authenticated agent's company" do
    expect(access.companies).to contain_exactly(company)
  end

  it "limits agents to coworkers" do
    expect(access.agents).to contain_exactly(agent)
  end

  it "limits contacts to the authenticated agent's company" do
    expect(access.contacts).to contain_exactly(contact)
  end

  it "limits provider accounts to the authenticated agent's company" do
    expect(access.whatsapp_accounts).to contain_exactly(account)
  end

  it "returns no records without an authenticated agent" do
    expect(described_class.new(nil).companies).to be_empty
    expect(described_class.new(nil).agents).to be_empty
    expect(described_class.new(nil).contacts).to be_empty
    expect(described_class.new(nil).whatsapp_accounts).to be_empty
    expect(described_class.new(nil).phone_numbers).to be_empty
    expect(described_class.new(nil).phone_number_accesses).to be_empty
    expect(described_class.new(nil).messages).to be_empty
    expect(described_class.new(nil).conversations).to be_empty
  end
end
