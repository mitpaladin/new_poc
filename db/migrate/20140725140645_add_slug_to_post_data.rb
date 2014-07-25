class AddSlugToPostData < ActiveRecord::Migration
  def change
    add_column :post_data, :slug, :string
  end
end
