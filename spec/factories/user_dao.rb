
FactoryGirl.define do
  sequence :name do |n|
    "J Random User Number #{n}"
  end

  sequence :email do |n|
    "jruser#{n}@example.com"
  end

  factory :user, class: 'UserDao' do
    name { generate :name }
    email { generate :email }
    profile 'Just Another *Random* User'
    password 'password'
    password_confirmation 'password'

    trait :new_user do
      slug nil
    end

    trait :saved_user do
      slug { name.parameterize }
    end
  end
end
