# == Schema Information
#
# Table name: post_data
#
#  id          :integer          not null, primary key
#  title       :string(255)      not null
#  body        :text
#  created_at  :datetime
#  updated_at  :datetime
#  image_url   :string(255)
#  pubdate     :datetime
#  author_name :string(255)
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  sequence :title do |n|
    "Test Title Number #{n}"
  end

  factory :post_datum, class: 'PostData' do
    title { generate :title }
    body 'The Body'
    image_url 'http://example.com/image1.png'
  end
end
