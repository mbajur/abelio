class Block::ImageSet < ApplicationRecord
  has_one :block, as: :blockable, dependent: :destroy
end
