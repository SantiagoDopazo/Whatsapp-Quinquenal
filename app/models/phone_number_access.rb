class PhoneNumberAccess < ApplicationRecord
  belongs_to :agent
  belongs_to :phone_number

  validates :phone_number_id, uniqueness: { scope: :agent_id }
  validate :same_company

  private

  def same_company
    if agent && phone_number && agent.company_id != phone_number.company_id
      errors.add(:agent, "must belong to the number's company")
    end
  end
end
