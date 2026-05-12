FactoryBot.define do
  factory :article do
    name { "MyString" }
    summary { "MyText" }
    content { "MyText" }
    raw_data { "" }
  end
end
