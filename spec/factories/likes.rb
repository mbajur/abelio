FactoryBot.define do
  factory :like do
    user { association :user }
    site { user.site }
    likeable { association :post, site: user.site }
    federails_activity { association :federails_activity }
  end
end
