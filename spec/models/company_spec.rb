require "rails_helper"

RSpec.describe Company, type: :model do
  it "requires a name" do
    expect(build(:company, name: " ")).not_to be_valid
  end

  it "does not delete a company with contacts" do
    contact = create(:contact)

    expect(contact.company.destroy).to be(false)
    expect(contact.reload).to be_persisted
  end

  it "does not delete a company with agents" do
    agent = create(:agent)

    expect(agent.company.destroy).to be(false)
    expect(agent.reload).to be_persisted
  end

  it "returns only conversations belonging to its contacts" do
    conversation = create(:conversation)
    create(:conversation)

    expect(conversation.company.conversations).to contain_exactly(conversation)
  end
end
