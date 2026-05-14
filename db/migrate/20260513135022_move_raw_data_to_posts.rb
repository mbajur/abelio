class MoveRawDataToPosts < ActiveRecord::Migration[8.1]
  def change
    add_column :posts, :raw_data, :json, default: "{}"
    remove_column :notes, :raw_data, :json
    remove_column :articles, :raw_data, :json
  end
end
