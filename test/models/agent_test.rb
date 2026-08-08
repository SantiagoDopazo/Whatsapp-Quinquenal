require "test_helper"

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
class AgentTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
