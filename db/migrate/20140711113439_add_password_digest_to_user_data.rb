class AddPasswordDigestToUserData < ActiveRecord::Migration
  def change
    add_column :user_data, :password_digest, :string
  end
end
