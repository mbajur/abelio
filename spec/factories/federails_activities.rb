FactoryBot.define do
  factory :federails_activity, class: "Federails::Activity" do
    actor { nil }
    action { "Like" }
    entity { nil }
  end
end
