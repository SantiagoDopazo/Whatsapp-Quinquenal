# == Schema Information
#
# Table name: agents
#
#  id                     :bigint           not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  jti                    :string           not null
#  name                   :string           not null
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  role                   :string           default("agent"), not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_agents_on_email                 (email) UNIQUE
#  index_agents_on_jti                   (jti) UNIQUE
#  index_agents_on_reset_password_token  (reset_password_token) UNIQUE
#
class Agent < ApplicationRecord
  ROLES = %w[admin agent].freeze

  # No :registerable (agents are created by an admin, not self-signup) and
  # no :rememberable/:trackable (meaningless for stateless JWT auth).
  devise :database_authenticatable, :recoverable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: JwtDenylist

  belongs_to :company
  has_many :conversations, dependent: :nullify

  validates :name, presence: true
  validates :role, inclusion: { in: ROLES }
  validate :company_cannot_change, on: :update

  before_create { self.jti = SecureRandom.uuid }

  private

  def company_cannot_change
    errors.add(:company, "cannot be changed") if will_save_change_to_company_id?
  end
end
