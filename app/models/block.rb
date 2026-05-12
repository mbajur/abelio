class Block < ApplicationRecord
  acts_as_nested_set counter_cache: :children_count

  belongs_to :blockable, polymorphic: true
  belongs_to :resource, polymorphic: true

  delegated_type :blockable, types: %w[Block::RichText Block::ImageSet Block::Image]
  accepts_nested_attributes_for :blockable
end
