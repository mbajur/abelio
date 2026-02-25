class CreateBlockImages < ActiveRecord::Migration[8.1]
  def change
    create_table :block_images do |t|
      t.text :file_data

      t.timestamps
    end
  end
end
