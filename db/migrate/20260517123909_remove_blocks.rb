class RemoveBlocks < ActiveRecord::Migration[8.1]
  def change
    drop_table :blocks
  end
end
