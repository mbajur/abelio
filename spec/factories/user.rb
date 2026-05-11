FactoryBot.define do
  factory :user do
    sequence(:email_address) { |n| "user#{n}@example.com" }
    password { "password123" }
    password_confirmation { "password123" }
    site { association :site }
    sequence(:name) { |n| "User #{n}" }
  end
end
