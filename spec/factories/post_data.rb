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
#  slug        :string(255)
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
    author_name 'Just Anybody'

    trait :new_post do
      # See https://norman.github.io/friendly_id/file.Guide.html#Deciding_When_to_Generate_New_Slugs
      slug nil
      pubdate nil
    end

    trait :saved_post do
      slug { title.parameterize }
      pubdate { DateTime.now }
    end
  end
end
