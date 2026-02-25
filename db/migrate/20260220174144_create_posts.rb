class CreatePosts < ActiveRecord::Migration[8.1]
  def change
    create_table :posts do |t|
      t.references :site, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.text :content
      t.string :federated_url, null: true, default: nil
      t.references :federails_actor, null: true, foreign_key: true

      t.timestamps
    end
  end
end
