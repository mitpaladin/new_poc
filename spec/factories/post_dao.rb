
FactoryGirl.define do
  # sequence :title do |n|
  #   "Test Title Number #{n}"
  # end

  factory :post, class: 'PostDao' do
    title { generate :title }
    body 'The Body'
    image_url 'http://example.com/image1.png'
    author_name 'Just Anybody'
    pubdate nil
    slug nil

    trait :saved_post do
      # See https://norman.github.io/friendly_id/file.Guide.html#Deciding_When_to_Generate_New_Slugs
      slug { title.parameterize }
    end

    trait :published_post do
      pubdate { Time.now }
    end
  end
end
