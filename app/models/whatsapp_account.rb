class WhatsappAccount < ApplicationRecord
  STATUSES = %w[pending connected disabled].freeze

  belongs_to :company
  has_many :phone_numbers, dependent: :restrict_with_error

  validates :name, :external_id, presence: true
  validates :external_id, uniqueness: true
  validates :status, inclusion: { in: STATUSES }
  validate :company_cannot_change, on: :update

  private

  def company_cannot_change
    errors.add(:company, "cannot be changed") if will_save_change_to_company_id?
  end
end
