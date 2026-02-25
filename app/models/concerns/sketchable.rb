module Sketchable
  extend ActiveSupport::Concern

  included do
    belongs_to :sketch_of, class_name: "Post", optional: true
    has_many :sketches, class_name: "Post", foreign_key: :sketch_of_id, dependent: :nullify

    scope :sketches, -> { where.not(sketch_of_id: nil) }
    scope :non_sketches, -> { where(sketch_of_id: nil) }

    def sketch?
      sketch_of_id.present?
    end
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
