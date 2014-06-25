# == Schema Information
#
# Table name: blog_data
#
#  id       :integer          not null, primary key
#  title    :string(255)      not null
#  subtitle :string(255)
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :blog_datum, class: 'BlogData' do
    title 'Watching Paint Dry'
    subtitle 'The trusted source for drying paint news & opinion'
  end
end
