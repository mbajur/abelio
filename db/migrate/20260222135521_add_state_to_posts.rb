class AddStateToPosts < ActiveRecord::Migration[8.1]
  def change
    add_column :posts, :state, :string, null: false, default: "initialized"
  end
end
