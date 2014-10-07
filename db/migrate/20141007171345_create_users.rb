class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name
      t.string :slug
      t.string :password_digest
      t.string :email
      t.text :profile

      t.timestamps
    end
  end
end
