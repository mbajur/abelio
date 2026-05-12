class CreateArticles < ActiveRecord::Migration[8.1]
  def change
    create_table :articles do |t|
      t.string :name
      t.text :summary
      t.text :content
      t.json :raw_data

      t.timestamps
    end
  end
end
