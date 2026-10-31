class Message < ApplicationRecord
  OUTBOUND_PROGRESS = %w[queued sending accepted sent delivered read].freeze
  TRANSITIONS = {
    "queued" => %w[sending accepted sent delivered read failed],
    "sending" => %w[accepted sent delivered read failed unknown],
    "accepted" => %w[sent delivered read failed],
    "sent" => %w[delivered read failed],
    "delivered" => %w[read],
    "read" => [],
    "failed" => %w[delivered read],
    "unknown" => %w[accepted sent delivered read failed],
    "received" => []
  }.freeze

  belongs_to :conversation
  belongs_to :phone_number
  belongs_to :agent, optional: true

  enum :direction, { inbound: "inbound", outbound: "outbound" }, prefix: true
  enum :message_type, { text: "text", unsupported: "unsupported" }, prefix: true
  enum :status, TRANSITIONS.keys.index_by(&:itself), prefix: true

  before_validation :set_initial_values, on: :create
  after_create :advance_conversation_activity

  validates :direction, :message_type, :status, :occurred_at, :status_at, presence: true
  validates :body, presence: true, if: :message_type_text?
  validates :external_id, presence: true, if: -> { direction_inbound? || status.in?(%w[accepted sent delivered read]) }
  validates :external_id, uniqueness: { scope: :phone_number_id }, allow_nil: true
  validates :client_request_id, presence: true, if: :direction_outbound?
  validates :client_request_id, uniqueness: { scope: :phone_number_id }, allow_nil: true
  validates :agent, presence: true, on: :create, if: :direction_outbound?
  validate :references_are_consistent
  validate :state_matches_direction
  validate :persisted_identity_cannot_change, on: :update
  validate :state_transition_is_valid, on: :update

  def record_status!(next_status, at:, external_id: nil)
    with_lock do
      if next_status.to_s == status
        next false
      end
      if OUTBOUND_PROGRESS.include?(status) && OUTBOUND_PROGRESS.include?(next_status.to_s) &&
          OUTBOUND_PROGRESS.index(next_status.to_s) < OUTBOUND_PROGRESS.index(status)
        next false
      end

      self.external_id = external_id if external_id.present?
      update!(status: next_status, status_at: [ status_at, at ].max)
    end
  end

  private

  def set_initial_values
    self.phone_number ||= conversation&.phone_number
    self.status ||= direction_inbound? ? "received" : "queued"
    self.occurred_at ||= Time.current
    self.status_at ||= occurred_at
    self.client_request_id ||= SecureRandom.uuid if direction_outbound?
  end

  def references_are_consistent
    if conversation && phone_number && conversation.phone_number_id != phone_number.id
      errors.add(:phone_number, "must match the conversation's line")
    end
    if agent && phone_number && agent.company_id != phone_number.company_id
      errors.add(:agent, "must belong to the number's company")
    end
  end

  def state_matches_direction
    if direction_inbound?
      errors.add(:status, "must be received for inbound messages") unless status_received?
      errors.add(:agent, "must be absent for inbound messages") if agent
    elsif direction_outbound?
      errors.add(:status, "cannot be received for outbound messages") if status_received?
      errors.add(:message_type, "must be text for outbound messages") unless message_type_text?
    end
  end

  def persisted_identity_cannot_change
    %w[conversation_id phone_number_id agent_id direction message_type body occurred_at client_request_id].each do |attribute|
      errors.add(attribute, "cannot be changed") if will_save_change_to_attribute?(attribute)
    end
    if external_id_in_database.present? && will_save_change_to_external_id?
      errors.add(:external_id, "cannot be changed once assigned")
    end
  end

  def state_transition_is_valid
    if status_at && status_at_in_database && status_at < status_at_in_database
      errors.add(:status_at, "cannot move backwards")
    end
    if will_save_change_to_status? && !TRANSITIONS.fetch(status_in_database, []).include?(status)
      errors.add(:status, "transition is not allowed")
    end
  end

  def advance_conversation_activity
    Conversation.where(id: conversation_id)
      .where("last_activity_at IS NULL OR last_activity_at < ?", occurred_at)
      .update_all(last_activity_at: occurred_at)
  end
end
