FactoryBot.define do
  factory :template do
    sequence(:name) { |n| "Template #{n}" }
    markup { "<html><body><h1>Test</h1></body></html>" }
  end
end
