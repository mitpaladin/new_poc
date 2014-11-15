class DropPostDataTable < ActiveRecord::Migration
  def change
    drop_table :post_data
  end
end
