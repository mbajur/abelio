class Block::RichText < ApplicationRecord
  has_one :block, as: :blockable, dependent: :destroy

  has_rich_text :content
end
