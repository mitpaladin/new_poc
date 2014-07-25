class AddSlugToUserData < ActiveRecord::Migration
  def change
    add_column :user_data, :slug, :string
  end
end
