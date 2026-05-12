class AddPostableToPosts < ActiveRecord::Migration[8.1]
  def change
    add_reference :posts, :postable, polymorphic: true, null: false
  end
end
