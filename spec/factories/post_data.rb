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

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :post_datum, class: 'PostData' do
    title 'The Title'
    body 'The Body'
  end
end
