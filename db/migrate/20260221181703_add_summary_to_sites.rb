class AddSummaryToSites < ActiveRecord::Migration[8.1]
  def change
    add_column :sites, :summary, :text
  end
end
