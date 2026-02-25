class AddTemplateToSite < ActiveRecord::Migration[8.1]
  def change
    add_reference :sites, :template, null: true, foreign_key: true
  end
end
