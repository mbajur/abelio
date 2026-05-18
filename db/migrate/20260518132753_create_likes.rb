class CreateLikes < ActiveRecord::Migration[8.1]
  def change
    create_table :likes do |t|
      t.references :user, null: false, foreign_key: { to_table: :users }
      t.references :site, null: false, foreign_key: { to_table: :sites }
      t.references :likeable, polymorphic: true, null: false
      t.references :federails_activity, null: false, foreign_key: { to_table: :federails_activities }

      t.timestamps
    end

    add_index :likes, [ :user_id, :likeable_type, :likeable_id ], unique: true
  end
end
