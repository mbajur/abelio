class CreateMedia < ActiveRecord::Migration[8.1]
  def change
    create_table :media do |t|
      t.json :file_data

      t.timestamps
    end
  end
end
