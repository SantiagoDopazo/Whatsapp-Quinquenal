class Company < ApplicationRecord
  has_many :agents, dependent: :restrict_with_error
  has_many :contacts, dependent: :restrict_with_error
  has_many :conversations, through: :contacts

  validates :name, presence: true
end
