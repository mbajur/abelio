FactoryBot.define do
  factory :federails_actor, class: "Federails::Actor" do
    sequence(:uuid) { |n| "xxxxxxxx-xxxx-xxxx-xxxx-#{'x' * (12 - n.to_s.length)}#{n}" }
    sequence(:federated_url) { |n| "https://example.com/users/actor#{n}" }
    entity_type { "User" }
    association :entity, factory: :user

    trait :remote do
      entity_type { nil }
      entity_id { nil }
    end
  end
end
