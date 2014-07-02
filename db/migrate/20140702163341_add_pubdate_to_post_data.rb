class AddPubdateToPostData < ActiveRecord::Migration
  def change
    add_column :post_data, :pubdate, :datetime
  end
end
