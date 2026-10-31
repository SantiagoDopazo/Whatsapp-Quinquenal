class PhoneNumber < ApplicationRecord
  STATUSES = %w[pending connected disabled].freeze

  belongs_to :whatsapp_account
  has_many :conversations, dependent: :restrict_with_error

  delegate :company, :company_id, to: :whatsapp_account

  validates :name, :external_id, :display_phone_number, presence: true
  validates :external_id, uniqueness: true
  validates :status, inclusion: { in: STATUSES }
  validate :account_cannot_change, on: :update

  private

  def account_cannot_change
    errors.add(:whatsapp_account, "cannot be changed") if will_save_change_to_whatsapp_account_id?
  end
end
