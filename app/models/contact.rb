# == Schema Information
#
# Table name: contacts
#
#  id          :bigint           not null, primary key
#  metadata    :jsonb            not null
#  name        :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  whatsapp_id :string           not null
#
# Indexes
#
#  index_contacts_on_whatsapp_id  (whatsapp_id) UNIQUE
#
class Contact < ApplicationRecord
  belongs_to :company
  has_many :conversations, dependent: :destroy

  validates :whatsapp_id, presence: true, uniqueness: { scope: :company_id }
  validate :company_cannot_change, on: :update

  private

  def company_cannot_change
    errors.add(:company, "cannot be changed") if will_save_change_to_company_id?
  end
end
