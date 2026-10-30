require "rails_helper"

RSpec.describe "Company authorization", type: :request do
  let_it_be(:company) { create(:company) }
  let_it_be(:admin) { create(:agent, company: company, role: "admin") }
  let_it_be(:coworker) { create(:agent, company: company) }
  let_it_be(:outsider) { create(:agent) }
  let_it_be(:contact) { create(:contact, company: company, name: "Own customer") }
  let_it_be(:foreign_contact) { create(:contact, name: "Foreign customer") }
  let_it_be(:foreign_conversation) { create(:conversation, contact: foreign_contact) }
  let_it_be(:conversation, refind: true) { create(:conversation, contact: contact) }

  before { post "/login", params: { email: admin.email, password: "password123" } }

  it "allows a colleague and hides agents in another company" do
    get "/agents/#{coworker.id}", as: :json
    expect(response).to have_http_status(:ok)
    get "/agents/#{outsider.id}", as: :json
    expect(response).to have_http_status(:not_found)
  end

  it "scopes administrative lists and association lookups" do
    get "/avo/resources/contacts"
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Own customer")
    expect(response.body).not_to include("Foreign customer")
    get "/avo/resources/companies"
    expect(response).to have_http_status(:ok)
    Avo::Current.set(user: admin) do
      expect(Avo::Resources::Contact.find_scope.pluck(:id)).to eq([ contact.id ])
    end
  end

  it "rejects reads, edits and deletes of foreign resources" do
    get "/avo/resources/conversations/#{foreign_conversation.id}"
    expect(response).to have_http_status(:not_found)
    patch "/avo/resources/contacts/#{foreign_contact.id}", params: { contact: { name: "Changed" } }
    expect(response).to have_http_status(:not_found)
    delete "/avo/resources/agents/#{outsider.id}"
    expect(response).to have_http_status(:not_found)
    expect(foreign_contact.reload.name).to eq("Foreign customer")
    expect(Agent.exists?(outsider.id)).to be(true)
  end

  it "rejects cross-company association IDs on create" do
    expect {
      post "/avo/resources/conversations", params: { conversation: { contact_id: foreign_contact.id } }
    }.not_to change(Conversation, :count)
    expect(response).to have_http_status(:not_found)
  end

  it "rejects foreign agents on an existing conversation" do
    patch "/avo/resources/conversations/#{conversation.id}", params: { conversation: { agent_id: outsider.id } }
    expect(response).to have_http_status(:not_found)
    expect(conversation.reload.agent).to be_nil
  end

  it "rejects a submitted foreign company instead of trusting request ownership" do
    expect {
      post "/avo/resources/contacts", params: { contact: { company_id: outsider.company_id, whatsapp_id: "injected-company" } }
    }.not_to change(Contact, :count)
    expect(response).to have_http_status(:not_found)
    get "/avo/resources/companies/#{outsider.company_id}"
    expect(response).to have_http_status(:not_found)
  end

  it "allows an administrator to update its own conversation" do
    patch "/avo/resources/conversations/#{conversation.id}", params: { conversation: { agent_id: coworker.id } }
    expect(response).to have_http_status(:redirect)
    expect(conversation.reload.agent).to eq(coworker)
  end

  it "derives ownership when creating a contact" do
    post "/avo/resources/contacts", params: { contact: { whatsapp_id: "synthetic-04", name: "Local" } }
    expect(response).to have_http_status(:redirect)
    expect(Contact.find_by!(whatsapp_id: "synthetic-04").company).to eq(company)
  end

  it "prevents tenant administrators from creating companies" do
    expect {
      post "/avo/resources/companies", params: { company: { name: "Injected" } }
    }.not_to change(Company, :count)
    expect(response).to have_http_status(:forbidden)
  end

  context "as an operator" do
    before { post "/login", params: { email: coworker.email, password: "password123" } }

    it "denies administrative mutations including self-promotion" do
      patch "/avo/resources/agents/#{coworker.id}", params: { agent: { role: "admin" } }
      expect(response).to have_http_status(:forbidden)
      expect(coworker.reload.role).to eq("agent")
    end
  end

  context "without authentication" do
    before { delete "/logout" }

    it "requires login for API and administration" do
      get "/agents/#{coworker.id}", as: :json
      expect(response).to have_http_status(:unauthorized)
      get "/avo/resources/contacts"
      expect(response).to redirect_to("/login")
    end
  end
end
