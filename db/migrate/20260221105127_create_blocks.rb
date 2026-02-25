class CreateBlocks < ActiveRecord::Migration[8.1]
  def change
    create_table :blocks do |t|
      t.integer :parent_id, null: true
      t.integer :lft, null: false
      t.integer :rgt, null: false
      t.integer :depth, null: false, default: 0
      t.integer :children_count, null: false, default: 0
      t.references :resource, polymorphic: true, null: false
      t.references :blockable, polymorphic: true, null: false

      t.timestamps
    end

    create_table :block_rich_texts do |t|
      t.text :content
    end

    create_table :block_image_sets

    add_index :blocks, :parent_id
    add_index :blocks, :lft
    add_index :blocks, :rgt
    add_index :blocks, :depth
  end
end
