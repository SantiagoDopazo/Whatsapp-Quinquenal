FactoryBot.define do
  factory :whatsapp_account do
    company
    name { "Test account" }
    sequence(:external_id) { |n| "account-#{n}" }
    status { "pending" }
  end
end
