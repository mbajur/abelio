class ChangeDefaultPostStateToDraft < ActiveRecord::Migration[8.1]
  def change
    change_column_default :posts, :state, "draft"
  end
end
