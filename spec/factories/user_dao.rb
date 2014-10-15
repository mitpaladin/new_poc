
FactoryGirl.define do
  # FIXME: Uncomment these when we eliminate :user_data factory.
  # sequence :name do |n|
  #   "J Random User Number #{n}"
  # end

  # sequence :email do |n|
  #   "jruser#{n}@example.com"
  # end

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

    # not to be used with :new_user
    trait :guest_user do
      name 'Guest User'
      email 'guest@example.com'
      profile %(This is the un-authenticated Guest User for the system.)
      password 'password'
      password_confirmation { password }
      slug { name.parameterize }
    end
  end
end
