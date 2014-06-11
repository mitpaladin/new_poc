class CreatePostData < ActiveRecord::Migration
  def change
    create_table :post_data do |t|
      t.string :title, null: false
      t.text :body

      t.timestamps
    end
  end
end
