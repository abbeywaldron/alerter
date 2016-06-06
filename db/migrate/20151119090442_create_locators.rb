class CreateLocators < ActiveRecord::Migration
  def change
    create_table :locators do |t|

      t.timestamps
    end
  end
end
