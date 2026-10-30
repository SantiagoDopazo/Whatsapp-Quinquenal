require "rails_helper"

RSpec.describe "Internal Avo access", type: :request do
  let_it_be(:developer) { create(:developer) }
  let_it_be(:admin) { create(:agent, role: "admin") }
  let_it_be(:operator) { create(:agent, company: admin.company) }
  let_it_be(:outsider) { create(:agent) }
  let_it_be(:contact, refind: true) { create(:contact, company: admin.company, name: "First company customer") }
  let_it_be(:other_contact, refind: true) { create(:contact, name: "Second company customer") }
  let_it_be(:conversation, refind: true) { create(:conversation, contact: contact) }

  context "with an internal developer session" do
    before { post "/login", params: { email: developer.email, password: "internal-password123" } }

    it "keeps the browser session and administers multiple companies" do
      expect(response).to redirect_to("/avo")
      get "/avo/resources/contacts"
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("First company customer", "Second company customer")
      get "/avo/resources/contacts/#{other_contact.id}"
      expect(response).to have_http_status(:ok)
      patch "/avo/resources/contacts/#{other_contact.id}", params: { contact: { name: "Updated by developer" } }
      expect(response).to have_http_status(:redirect)
      expect(other_contact.reload.name).to eq("Updated by developer")
    end

    it "does not create a company-agent session or issue an agent token" do
      expect(response.headers["Authorization"]).to be_nil
      get "/agents/#{admin.id}", as: :json
      expect(response).to have_http_status(:unauthorized)
    end

    it "requires an explicit company for contacts" do
      post "/avo/resources/contacts", params: { contact: { company_id: admin.company_id, whatsapp_id: "synthetic-internal" } }
      expect(response).to have_http_status(:redirect)
      expect(Contact.find_by!(whatsapp_id: "synthetic-internal").company).to eq(admin.company)
    end

    it "retains cross-company integrity even for internal users" do
      patch "/avo/resources/conversations/#{conversation.id}", params: { conversation: { agent_id: outsider.id } }
      expect(response).to have_http_status(:unprocessable_content)
      expect(conversation.reload.agent).to be_nil
    end

    it "allows internal provisioning of companies" do
      expect {
        post "/avo/resources/companies", params: { company: { name: "Provisioned company" } }
      }.to change(Company, :count).by(1)
      expect(response).to have_http_status(:redirect)
    end

    it "does not expose routes to create internal users" do
      post "/developers", params: { developer: { email: "injected@example.com", password: "password123" } }
      expect(response).to have_http_status(:not_found)
    end

    it "ends the internal session on logout" do
      delete "/logout"
      expect(response).to redirect_to("/login")
      get "/avo/resources/contacts"
      expect(response).to redirect_to("/login")
    end
  end

  it "does not accept company administrator credentials at the internal login" do
    post "/login", params: { email: admin.email, password: "password123" }
    expect(response).to have_http_status(:unprocessable_content)
    get "/avo/resources/agents/#{admin.id}"
    expect(response).to redirect_to("/login")
  end

  it "does not accept operator credentials at the internal login" do
    post "/login", params: { email: operator.email, password: "password123" }
    expect(response).to have_http_status(:unprocessable_content)
    get "/avo/resources/contacts"
    expect(response).to redirect_to("/login")
  end

  it "rejects the wrong password for an internal user" do
    post "/login", params: { email: developer.email, password: "incorrect-password" }
    expect(response).to have_http_status(:unprocessable_content)
    get "/avo/resources/companies"
    expect(response).to redirect_to("/login")
  end

  it "shows the internal login to unauthenticated users" do
    get "/avo/resources/companies"
    expect(response).to redirect_to("/login")
    get "/login"
    expect(response.body).to include("Solo para desarrolladores del sistema")
  end
end
