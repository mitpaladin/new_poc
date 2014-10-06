class DropBlogDataTable < ActiveRecord::Migration
  def change
    drop_table :blog_data
  end
end
