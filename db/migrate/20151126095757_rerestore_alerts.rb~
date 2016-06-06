class RestoreAlerts < ActiveRecord::Migration
  def change
    create_table :alerts do |t|
      t.datetime :issued_at
      t.integer :tags
      t.integer :threshold
      t.text :description
      t.boolean :active

      t.timestamps
    end


  end
end
