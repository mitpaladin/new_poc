
require 'spec_helper'

require 'support/random_item_array_generator'

# NOTE: Helper functions like this need to have unique names across ALL sources.
#       You Have Been Warned.
def bdds_build_example_posts(entry_count)
  FactoryGirl.build_list :post_datum, entry_count
end

def random_ages(sample, back_to_limit = 180)
  item_maker = -> (_index, current) { current.days.ago }
  RandomItemArrayGenerator.new(back_to_limit).generate sample, item_maker
end

def build_and_publish_posts(_blog, count = 10)
  ages = random_ages(count)
  bdds_build_example_posts(count).each_with_index do |post, index|
    post.pubdate = ages[index]
    post.save!
  end
end

describe BlogDataDecorator do

  let(:blog) { BlogData.first.decorate }

  describe :summarise do

    it 'returns a list of 10 entries by default' do
      build_and_publish_posts blog, 11
      post_entries = blog.summarise
      expect(post_entries.count).to eq 10
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
      unpublished_posts = bdds_build_example_posts(10 - published_post_count)
      unpublished_posts.each(&:save!)
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

    it 'decorates each PostData entry with a PostDataDecorator' do
      build_and_publish_posts blog
      entries = blog.summarise
      entries.each do |post|
        expect(post).to be_decorated_with PostDataDecorator
      end
    end

  end # describe :summarise

end
