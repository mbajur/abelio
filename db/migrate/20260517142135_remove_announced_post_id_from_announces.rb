class RemoveAnnouncedPostIdFromAnnounces < ActiveRecord::Migration[8.1]
  def change
    remove_column :announces, :announced_post_id, :bigint
  end
end
