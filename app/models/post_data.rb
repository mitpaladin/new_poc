# == Schema Information
#
# Table name: post_data
#
#  id         :integer          not null, primary key
#  title      :string(255)      not null
#  body       :text
#  created_at :datetime
#  updated_at :datetime
#

# PostData: ActiveRecord persistence for Posts.
class PostData < ActiveRecord::Base
  attr_accessor :title, :body
end
