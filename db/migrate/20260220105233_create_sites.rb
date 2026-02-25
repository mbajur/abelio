class CreateSites < ActiveRecord::Migration[8.1]
  def change
    create_table :sites do |t|
      t.string :domain
      t.text :logo_data
      t.string :name
      t.string :username

      t.timestamps
    end
    add_index :sites, :domain, unique: true
    add_index :sites, :username, unique: true
  end
end
