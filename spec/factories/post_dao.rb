
FactoryGirl.define do
  sequence :title do |n|
    "Test Title Number #{n}"
  end

  factory :post, class: 'PostDao' do
    title { generate :title }
    body 'The Body'
    author_name 'Just Anybody'
    image_url nil
    pubdate nil
    slug nil

    trait :image_post do
      image_url 'http://example.com/image1.png'
    end

    trait :saved_post do
      # See https://norman.github.io/friendly_id/file.Guide.html#Deciding_When_to_Generate_New_Slugs
      slug { title.parameterize }
    end

    trait :published_post do
      pubdate { Time.zone.now }
    end
  end
end
