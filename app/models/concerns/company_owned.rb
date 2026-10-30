module CompanyOwned
  extend ActiveSupport::Concern

  included do
    belongs_to :company
    validate :company_cannot_change, on: :update
  end

  private

  def company_cannot_change
    errors.add(:company, "cannot be changed") if will_save_change_to_company_id?
  end
end
