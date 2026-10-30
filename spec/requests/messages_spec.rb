require "rails_helper"

RSpec.describe "Message administration", type: :request do
  let_it_be(:admin) { create(:agent, role: "admin") }
  let_it_be(:contact) { create(:contact, company: admin.company) }
  let_it_be(:conversation) { create(:conversation, contact: contact) }
  let_it_be(:message, refind: true) { create(:message, conversation: conversation, body: "Own synthetic text") }
  let_it_be(:foreign_message) { create(:message, body: "Foreign synthetic text") }

  before { post "/login", params: { email: admin.email, password: "password123" } }

  it "shows only company messages" do
    get "/avo/resources/messages"
    expect(response).to have_http_status(:ok)
    expect(response.body).to include(message.external_id)
    expect(response.body).not_to include(foreign_message.external_id)
    get "/avo/resources/messages/#{message.id}"
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Own synthetic text")
    get "/avo/resources/messages/#{foreign_message.id}"
    expect(response).to have_http_status(:not_found)
  end

  it "blocks creating, changing and removing provider history from the CRUD" do
    post "/avo/resources/messages", params: { message: { conversation_id: conversation.id, body: "Injected" } }
    expect(response).to have_http_status(:forbidden)
    patch "/avo/resources/messages/#{message.id}", params: { message: { body: "Changed" } }
    expect(response).to have_http_status(:forbidden)
    delete "/avo/resources/messages/#{message.id}"
    expect(response).to have_http_status(:forbidden)
    expect(message.reload.body).to eq("Own synthetic text")
  end
end
