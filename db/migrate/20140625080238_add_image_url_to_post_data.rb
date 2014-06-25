
class AddImageUrlToPostData < ActiveRecord::Migration
  def change
    add_column :post_data, :image_url, :string
  end
end
