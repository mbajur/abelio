FactoryBot.define do
  factory :post do
    site { association :site }
    user { association :user, site: site }
    sequence(:name) { |n| "Post #{n}" }
    sequence(:published_at) { |n| n.days.ago }
    state { :published }
    likes_count { 0 }
    boosts_count { 0 }
    replies_count { 0 }
  end
end
