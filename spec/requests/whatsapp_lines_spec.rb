require "rails_helper"

RSpec.describe "WhatsApp line administration", type: :request do
  let_it_be(:admin) { create(:agent, role: "admin") }
  let_it_be(:operator) { create(:agent, company: admin.company) }
  let_it_be(:number) { create(:phone_number, company: admin.company) }
  let_it_be(:foreign_number) { create(:phone_number, name: "Foreign line") }

  before { post "/login", params: { email: admin.email, password: "password123" } }

  it "derives account ownership from the signed-in administrator" do
    post "/avo/resources/whatsapp_accounts", params: { whatsapp_account: { name: "Local account", external_id: "synthetic-account" } }
    expect(response).to have_http_status(:redirect)
    expect(WhatsappAccount.find_by!(external_id: "synthetic-account").company).to eq(admin.company)
  end

  it "scopes line lists and refuses foreign lines" do
    get "/avo/resources/phone_numbers"
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Test line")
    expect(response.body).not_to include("Foreign line")
    get "/avo/resources/phone_numbers/#{foreign_number.id}"
    expect(response).to have_http_status(:not_found)
  end

  it "does not grant access to a line in another company" do
    expect {
      post "/avo/resources/phone_number_accesses", params: { phone_number_access: { agent_id: operator.id, phone_number_id: foreign_number.id } }
    }.not_to change(PhoneNumberAccess, :count)
    expect(response).to have_http_status(:unprocessable_content)
  end

  it "allows an administrator to grant and revoke a company line" do
    post "/avo/resources/phone_number_accesses", params: { phone_number_access: { agent_id: operator.id, phone_number_id: number.id } }
    expect(response).to have_http_status(:redirect)
    expect(operator.can_access_phone_number?(number)).to be(true)
    delete response.location
    expect(response).to have_http_status(:redirect)
    expect(operator.can_access_phone_number?(number)).to be(false)
  end
end
