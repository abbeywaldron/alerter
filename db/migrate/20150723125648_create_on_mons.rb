class CreateOnMons < ActiveRecord::Migration
  def change
    create_table :on_mons do |t|

      t.timestamps
    end
  end
end
