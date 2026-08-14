# == Schema Information
#
# Table name: jwt_denylists
#
#  id         :bigint           not null, primary key
#  exp        :datetime
#  jti        :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_jwt_denylists_on_jti  (jti)
#

require "test_helper"

class JwtDenylistTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
