class RemovePostableFromAnnounces < ActiveRecord::Migration[8.1]
  def change
    remove_reference :announces, :postable, polymorphic: true
  end
end
