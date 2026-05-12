FactoryBot.define do
  factory :post do
    site { association :site }
    user { association :user, site: site }
    postable { association :article }
    sequence(:published_at) { |n| n.days.ago }
    state { :published }
    likes_count { 0 }
  end
end
