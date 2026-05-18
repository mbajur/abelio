class AddAnnounceOfToPosts < ActiveRecord::Migration[8.1]
  def change
    add_reference :posts, :announced_post, null: true, foreign_key: { to_table: :posts }
  end
end
