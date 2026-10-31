FactoryBot.define do
  factory :developer do
    sequence(:email) { |n| "developer#{n}@example.com" }
    name { "Test developer" }
    password { "internal-password123" }
  end
end
