class CreateCalibrators < ActiveRecord::Migration
  def change
    create_table :calibrators do |t|

      t.timestamps
    end
  end
end
