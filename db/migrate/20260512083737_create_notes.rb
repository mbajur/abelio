class CreateNotes < ActiveRecord::Migration[8.1]
  def change
    create_table :notes do |t|
      t.text :summary
      t.text :content
      t.json :raw_data

      t.timestamps
    end
  end
end
