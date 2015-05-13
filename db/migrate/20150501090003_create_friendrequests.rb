class CreateFriendrequests < ActiveRecord::Migration
  def change
    create_table :friendrequests do |t|
      t.integer :user_id
      t.integer :friend_id
      t.integer :status

      t.timestamps null: false
    end
  end
end
