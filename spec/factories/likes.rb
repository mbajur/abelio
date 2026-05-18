FactoryBot.define do
  factory :like do
    user { association :user }
    site { association :site }
    likeable { association :post }
    federails_activity { association :federails_activity }
  end
end
