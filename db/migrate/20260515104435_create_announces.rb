class CreateAnnounces < ActiveRecord::Migration[8.1]
  def change
    create_table :announces do |t|
      t.references :postable, polymorphic: true, null: false
      t.references :announced_post, null: false, foreign_key: { to_table: :posts }

      t.timestamps
    end
  end
end
