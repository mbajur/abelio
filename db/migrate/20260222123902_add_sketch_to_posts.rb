class AddSketchToPosts < ActiveRecord::Migration[8.1]
  def change
    add_reference :posts, :sketch_of, foreign_key: { to_table: :posts }
  end
end
