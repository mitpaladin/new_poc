class DropUserData < ActiveRecord::Migration
  def change
    drop_table :user_data
  end
end
