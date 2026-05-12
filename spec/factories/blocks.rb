FactoryBot.define do
  factory :block do
    association :resource, factory: :article
    association :blockable, factory: :block_rich_text
  end
end
