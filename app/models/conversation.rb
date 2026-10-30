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
class Conversation < ApplicationRecord
  belongs_to :contact
  belongs_to :agent, optional: true

  delegate :company, to: :contact, allow_nil: true

  validate :agent_belongs_to_contact_company

  enum :status, { open: 0, pending: 1, closed: 2 }, default: :open

  scope :unassigned, -> { where(agent_id: nil) }

  private

  def agent_belongs_to_contact_company
    if agent && contact && agent.company != contact.company
      errors.add(:agent, "must belong to the contact's company")
    end
  end
end
