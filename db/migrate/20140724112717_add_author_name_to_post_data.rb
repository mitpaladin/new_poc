class AddAuthorNameToPostData < ActiveRecord::Migration
  def change
    add_column :post_data, :author_name, :string
  end
end
