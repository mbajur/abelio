class RemoveBlockTypes < ActiveRecord::Migration[8.1]
  def change
    drop_table :block_image_sets
    drop_table :block_images
    drop_table :block_rich_texts
  end
end
