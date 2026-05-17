class CreateMedia < ActiveRecord::Migration[8.1]
  def change
    create_table :media do |t|
      t.json :file_data
      t.references :site, null: false, foreign_key: { to_table: :sites }
      t.string :entity_type
      t.bigint :entity_id

      t.timestamps
    end
  end
end
