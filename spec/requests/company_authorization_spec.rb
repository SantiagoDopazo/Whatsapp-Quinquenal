require "rails_helper"

RSpec.describe "Company API authorization", type: :request do
  let_it_be(:admin) { create(:agent, role: "admin") }
  let_it_be(:coworker) { create(:agent, company: admin.company) }
  let_it_be(:outsider) { create(:agent) }
  let(:authorization) { { "Authorization" => response.headers.fetch("Authorization") } }

  before do
    post "/agents/sign_in", params: { agent: { email: admin.email, password: "password123" } }, as: :json
    authorization
    cookies.delete("_whatsapp_quinquenal_session")
  end

  it "allows a colleague with an agent JWT" do
    get "/agents/#{coworker.id}", headers: authorization, as: :json
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body.fetch("id")).to eq(coworker.id)
  end

  it "hides agents in another company" do
    get "/agents/#{outsider.id}", headers: authorization, as: :json
    expect(response).to have_http_status(:not_found)
  end

  it "does not authorize administrative access with a company administrator's JWT" do
    get "/avo/resources/companies", headers: authorization
    expect(response).to have_http_status(:forbidden)
    expect {
      post "/avo/resources/companies", params: { company: { name: "Injected" } }, headers: authorization
    }.not_to change(Company, :count)
    expect(response).to have_http_status(:forbidden)
  end
end
