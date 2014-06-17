class CreateBlogData < ActiveRecord::Migration
  def change
    create_table :blog_data do |t|
      t.string :title, null: false
      t.string :subtitle
    end
  end
end
