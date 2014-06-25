# == Schema Information
#
# Table name: blog_data
#
#  id       :integer          not null, primary key
#  title    :string(255)      not null
#  subtitle :string(255)
#

class BlogData < ActiveRecord::Base
end
