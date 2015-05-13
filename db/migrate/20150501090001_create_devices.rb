class CreateDevices < ActiveRecord::Migration
  def change
    create_table :devices do |t|
      t.integer :user_id
      t.string :os
      t.string :push_token
      t.string :status

      t.timestamps null: false
    end
  end
end
