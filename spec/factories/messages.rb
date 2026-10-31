FactoryBot.define do
  factory :message do
    conversation
    phone_number { conversation.phone_number }
    direction { "inbound" }
    message_type { "text" }
    body { "Synthetic question" }
    sequence(:external_id) { |n| "message-#{n}" }
    occurred_at { Time.current }

    trait :outbound do
      direction { "outbound" }
      external_id { nil }
      agent { association(:agent, company: conversation.company, role: "admin") }
    end
  end
end
