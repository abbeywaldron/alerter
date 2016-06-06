class AddActiveToAlert < ActiveRecord::Migration
  def change
    add_column :alerts, :active, :boolean
  end
end
