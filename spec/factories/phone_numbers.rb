FactoryBot.define do
  factory :phone_number do
    transient do
      company { association(:company) }
    end

    whatsapp_account { association(:whatsapp_account, company: company) }
    name { "Test line" }
    sequence(:external_id) { |n| "line-#{n}" }
    sequence(:display_phone_number) { |n| "test-number-#{n}" }
    status { "pending" }
  end
end
