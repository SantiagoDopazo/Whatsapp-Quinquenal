class Company < ApplicationRecord
  has_many :agents, dependent: :restrict_with_error
  has_many :contacts, dependent: :restrict_with_error
  has_many :conversations, through: :contacts
  has_many :messages, through: :conversations
  has_many :whatsapp_accounts, dependent: :restrict_with_error
  has_many :phone_numbers, through: :whatsapp_accounts

  validates :name, presence: true
end
