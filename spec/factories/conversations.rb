# == Schema Information
#
# Table name: conversations
#
#  id               :bigint           not null, primary key
#  last_activity_at :datetime
#  status           :integer          default(0), not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  agent_id         :bigint
#  contact_id       :bigint           not null
#
# Indexes
#
#  index_conversations_on_agent_id    (agent_id)
#  index_conversations_on_contact_id  (contact_id)
#
# Foreign Keys
#
#  fk_rails_...  (agent_id => agents.id)
#  fk_rails_...  (contact_id => contacts.id)
#
FactoryBot.define do
  factory :conversation do
    contact
    phone_number { association(:phone_number, company: contact&.company || association(:company)) }
    status { "open" }
    last_activity_at { Time.current }
  end
end
