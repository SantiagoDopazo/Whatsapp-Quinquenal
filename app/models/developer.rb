class Developer < ApplicationRecord
  devise :database_authenticatable, :validatable

  validates :name, presence: true
end
