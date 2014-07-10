class CreateUserData < ActiveRecord::Migration
  def change
    create_table :user_data do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.text :profile

      t.timestamps
    end
  end
end
