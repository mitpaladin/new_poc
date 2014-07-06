
require 'spec_helper'

require 'support/random_item_array_generator'

def build_example_posts(entry_count)
  Array.new(entry_count).fill do
    Post.new(FactoryGirl.attributes_for :post_datum)
  end
end

def random_ages(sample, back_to_limit = 180)
  item_maker = -> (_index, current) { current.days.ago }
  RandomItemArrayGenerator.new(back_to_limit).generate sample, item_maker
end

def build_and_publish_posts(blog, count = 10)
  ages = random_ages(count)
  build_example_posts(count).each_with_index do |post, index|
    post.blog = blog
    post.publish ages[index]
  end
end

describe BlogDecorator do

  let(:blog) { BlogDecorator.decorate Blog.new }

  describe :summarise do

    it 'returns a list of 10 entries by default' do
      build_and_publish_posts blog, 11
      entries = blog.summarise
      expect(entries.count).to eq 10
    end

    describe 'returns a list of a valid length specified by a parameter' do

      context 'when the specified number of entries exist' do

        after :each do
          entry_count = Integer(RSpec.current_example.description)
          build_and_publish_posts blog, (entry_count * 2)
          entries = blog.summarise entry_count
          expect(entries.count).to eq entry_count
        end

        it '1' do
        end

        it '10' do
        end

        it '50' do
        end

      end # context 'when the specified number of entries exist'

      context 'when there are fewer than the specified number of entries' do

        it '5' do
          entry_count = Integer(RSpec.current_example.description)
          expected_count = entry_count / 2
          build_and_publish_posts blog, expected_count
          entries = blog.summarise entry_count
          expect(entries.count).to eq expected_count
        end

      end # context 'when there are fewer than the specified number of entries'

    end # describe 'returns a list of a valid length specified by a parameter'

    it 'includes only published entries' do
      published_post_count = 8
      build_and_publish_posts blog, published_post_count
      unpublished_posts = build_example_posts(10 - published_post_count)
      unpublished_posts.each { |post| blog.add_entry post }
      entries = blog.summarise
      expect(entries.count).to eq published_post_count
      entries.each { |post| expect(post).to be_published }
    end

    it 'sorts the entries in reverse order by pubdate' do
      build_and_publish_posts blog
      entries = blog.summarise
      last_date = DateTime.now
      entries.each do |post|
        expect(post.pubdate < last_date).to be true
        last_date = post.pubdate
      end
    end

  end # describe :summarise

end
