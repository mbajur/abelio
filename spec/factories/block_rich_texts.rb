FactoryBot.define do
  factory :block_rich_text, class: "Block::RichText" do
    content { "<p>Hello world</p>" }
  end
end
