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
  belongs_to :phone_number, optional: true

  delegate :company, to: :contact, allow_nil: true

  validate :agent_belongs_to_contact_company
  validates :phone_number, presence: true, on: :create
  validates :contact_id, uniqueness: {
    scope: :phone_number_id, conditions: -> { where(status: [ :open, :pending ]) }
  }, if: -> { phone_number_id.present? && !closed? }
  validate :phone_number_belongs_to_contact_company,
    if: -> { phone_number.present? && contact.present? }
  validate :identity_cannot_change, on: :update

  enum :status, { open: 0, pending: 1, closed: 2 }, default: :open

  scope :unassigned, -> { where(agent_id: nil) }

  private

  def phone_number_belongs_to_contact_company
    if phone_number.company != contact.company
      errors.add(:phone_number, "must belong to the contact's company")
    end
  end

  def identity_cannot_change
    errors.add(:contact, "cannot be changed") if will_save_change_to_contact_id?
    if phone_number_id_in_database.present? && will_save_change_to_phone_number_id?
      errors.add(:phone_number, "cannot be changed once assigned")
    end
  end

  def agent_belongs_to_contact_company
    if agent && contact && agent.company != contact.company
      errors.add(:agent, "must belong to the contact's company")
    end
  end
end
