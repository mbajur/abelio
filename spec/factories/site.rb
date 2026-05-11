FactoryBot.define do
  factory :site do
    sequence(:domain) { |n| "example#{n}.com" }
    sequence(:name) { |n| "Site #{n}" }
    username { domain }
    template { association :template }

    trait :with_logo do
      # Add logo if your Site model supports it
    end
  end
end
