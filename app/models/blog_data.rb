# == Schema Information
#
# Table name: blog_data
#
#  id         :integer          not null, primary key
#  title      :string(255)      not null
#  subtitle   :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class BlogData < ActiveRecord::Base
end
