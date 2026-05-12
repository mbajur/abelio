module Blockable
  extend ActiveSupport::Concern

  included do
    has_many :blocks, as: :resource, dependent: :destroy
    accepts_nested_attributes_for :blocks
  end

  # Recursively rebuild the block tree for the new post while preserving
  # parent/child hierarchy and block order.
  def duplicate_blocks(source_blocks, parent: nil)
    source_blocks.each do |source_block|
      new_blockable = duplicate_blockable(source_block)
      new_blockable.save!

      new_block = blocks.new(
        blockable: new_blockable,
        parent: parent,
        resource: self
      )
      new_block.save!

      duplicate_blocks(source_block.children.order(:lft), parent: new_block)
    end
  end

  # Clone the polymorphic blockable (rich text, image set, image, etc.)
  # and copy any rich content so the new post has its own data.
  def duplicate_blockable(source_block)
    blockable = source_block.blockable
    new_blockable = blockable.dup

    if new_blockable.respond_to?(:content) && blockable.respond_to?(:content)
      content_value = blockable.content
      new_blockable.content = content_value.to_s if content_value.present?
    end

    new_blockable
  end
end
