class CreateMyRequests < ActiveRecord::Migration
  def change
    create_table :my_requests do |t|

      t.timestamps
    end
  end
end
