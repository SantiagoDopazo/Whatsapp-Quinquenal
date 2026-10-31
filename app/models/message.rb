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
  with_options if: :direction_inbound? do
    validates :status, inclusion: { in: %w[received], message: "must be received for inbound messages" }
    validates :agent, absence: { message: "must be absent for inbound messages" }
  end

  with_options if: :direction_outbound? do
    validates :status, exclusion: { in: %w[received], message: "cannot be received for outbound messages" }
    validates :message_type, inclusion: { in: %w[text], message: "must be text for outbound messages" }
  end

  validate :phone_number_matches_conversation,
    if: -> { conversation.present? && phone_number.present? }
  validate :agent_belongs_to_phone_number_company,
    if: -> { agent.present? && phone_number.present? }
  validate :content_and_origin_cannot_change, on: :update
  validate :external_id_cannot_change, on: :update,
    if: -> { external_id_in_database.present? && will_save_change_to_external_id? }
  validate :status_time_cannot_move_backwards, on: :update,
    if: -> { status_at.present? && status_at_in_database.present? }
  validate :status_transition_is_allowed, on: :update, if: :will_save_change_to_status?

  def record_status!(next_status, at:, external_id: nil)
    next_status = next_status.to_s

    with_lock do
      next false if next_status == status
      next false if earlier_status?(next_status)

      self.external_id = external_id if external_id.present?
      update!(status: next_status, status_at: [ status_at, at ].max)
    end
  end

  private

  def earlier_status?(next_status)
    current_position = OUTBOUND_PROGRESS.index(status)
    next_position = OUTBOUND_PROGRESS.index(next_status)

    return false unless current_position && next_position

    next_position < current_position
  end

  def set_initial_values
    self.phone_number ||= conversation&.phone_number
    self.status ||= direction_inbound? ? "received" : "queued"
    self.occurred_at ||= Time.current
    self.status_at ||= occurred_at
    self.client_request_id ||= SecureRandom.uuid if direction_outbound?
  end

  def phone_number_matches_conversation
    if conversation.phone_number_id != phone_number.id
      errors.add(:phone_number, "must match the conversation's line")
    end
  end

  def agent_belongs_to_phone_number_company
    if agent.company_id != phone_number.company_id
      errors.add(:agent, "must belong to the number's company")
    end
  end

  def content_and_origin_cannot_change
    %w[conversation_id phone_number_id agent_id direction message_type body occurred_at client_request_id].each do |attribute|
      errors.add(attribute, "cannot be changed") if will_save_change_to_attribute?(attribute)
    end
  end

  def external_id_cannot_change
    errors.add(:external_id, "cannot be changed once assigned")
  end

  def status_time_cannot_move_backwards
    errors.add(:status_at, "cannot move backwards") if status_at < status_at_in_database
  end

  def status_transition_is_allowed
    unless TRANSITIONS.fetch(status_in_database, []).include?(status)
      errors.add(:status, "transition is not allowed")
    end
  end

  def advance_conversation_activity
    Conversation.where(id: conversation_id)
      .where("last_activity_at IS NULL OR last_activity_at < ?", occurred_at)
      .update_all(last_activity_at: occurred_at)
  end
end
