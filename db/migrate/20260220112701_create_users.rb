class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :email_address, null: false
      t.string :password_digest, null: false
      t.references :site, null: false, foreign_key: { to_table: :sites }
      t.string :name
      t.string :username

      t.timestamps
    end
    add_index :users, :email_address, unique: true
    add_index :users, :username, unique: true
  end
end
