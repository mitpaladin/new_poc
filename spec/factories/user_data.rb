# == Schema Information
#
# Table name: user_data
#
#  id              :integer          not null, primary key
#  name            :string(255)      not null
#  email           :string(255)      not null
#  profile         :text
#  created_at      :datetime
#  updated_at      :datetime
#  password_digest :string(255)
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  sequence :name do |n|
    "J Random User Number #{n}"
  end

  factory :user_datum, class: 'UserData' do
    name { generate :name }
    email 'jruser@example.com'
    profile 'Just Another Random User'
    password 'password'
    password_confirmation 'password'
  end
end
