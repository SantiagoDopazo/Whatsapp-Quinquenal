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
FactoryBot.define do
  factory :contact do
    sequence(:whatsapp_id) { |n| "54911000000#{n}" }
    name { "Test Contact" }
  end
end
