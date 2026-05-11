class AddAnnouncesCountToPosts < ActiveRecord::Migration[8.1]
  def change
    add_column :posts, :announces_count, :integer, default: 0
  end
end
