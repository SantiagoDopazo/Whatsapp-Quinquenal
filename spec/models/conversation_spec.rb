require "rails_helper"

# == Schema Information
#
# Table name: conversations
#
#  id               :bigint           not null, primary key
#  last_activity_at :datetime
#  status           :integer          default(0), not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  agent_id         :bigint
#  contact_id       :bigint           not null
#
# Indexes
#
#  index_conversations_on_agent_id    (agent_id)
#  index_conversations_on_contact_id  (contact_id)
#
# Foreign Keys
#
#  fk_rails_...  (agent_id => agents.id)
#  fk_rails_...  (contact_id => contacts.id)
#
RSpec.describe Conversation, type: :model do
  describe "associations" do
    it "belongs to a contact" do
      expect(described_class.reflect_on_association(:contact).macro).to eq(:belongs_to)
    end

    it "optionally belongs to an agent" do
      expect(described_class.reflect_on_association(:agent).options[:optional]).to be(true)
    end
  end

  describe "status" do
    let(:conversation) { create(:conversation) }

    it "defaults to open" do
      expect(conversation.status).to eq("open")
    end
  end

  describe ".unassigned" do
    let!(:unassigned_conversation) { create(:conversation, agent: nil) }
    let!(:assigned_conversation) { create(:conversation, agent: create(:agent)) }

    it "returns only conversations without an agent" do
      expect(described_class.unassigned).to contain_exactly(unassigned_conversation)
    end
  end

  describe "record lifecycle" do
    it "requires a contact" do
      conversation = build(:conversation, contact: nil)

      expect(conversation).not_to be_valid
      expect(conversation.errors[:contact]).to be_present
    end

    it "preserves the conversation when its assigned agent is deleted" do
      agent = create(:agent)
      conversation = create(:conversation, agent: agent)

      agent.destroy!

      expect(conversation.reload.agent_id).to be_nil
      expect(conversation.contact).to be_present
    end

    it "removes conversations when their contact is deleted" do
      conversation = create(:conversation)

      expect { conversation.contact.destroy! }
        .to change { described_class.exists?(conversation.id) }.from(true).to(false)
    end

    it "persists closing and reopening a conversation" do
      conversation = create(:conversation)

      conversation.closed!
      expect(conversation.reload).to be_closed

      conversation.open!
      expect(conversation.reload).to be_open
    end
  end
end
