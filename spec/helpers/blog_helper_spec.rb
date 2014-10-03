
require 'spec_helper'

# NOTE: Helper functions like this need to have unique names across ALL sources.
#       You Have Been Warned.

def bhs_build_example_posts(entry_count)
  FactoryGirl.build_list :post_datum, entry_count
end

def random_ages(sample, back_to_limit = 180)
  item_maker = -> (_index, current) { current.days.ago }
  RandomItemArrayGenerator.new(back_to_limit).generate sample, item_maker
end

def build_and_publish_posts(count = 10)
  ages = random_ages(count)
  bhs_build_example_posts(count).each_with_index do |post, index|
    post.pubdate = ages[index]
    post.save!
  end
end

describe BlogHelper do
  describe 'summarise_blog' do

    it 'returns a list of 10 entries by default' do
      build_and_publish_posts 11
      post_entries = summarise_blog
      expect(post_entries.count).to eq 10
    end

    describe 'returns a list of a valid length specified by a parameter' do

      context 'when the specified number of entries exist' do

        after :each do
          entry_count = Integer(RSpec.current_example.description)
          build_and_publish_posts entry_count * 2
          entries = summarise_blog entry_count
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
          build_and_publish_posts expected_count
          entries = summarise_blog entry_count
          expect(entries.count).to eq expected_count
        end

      end # context 'when there are fewer than the specified number of entries'

    end # describe 'returns a list of a valid length specified by a parameter'

    describe 'includes both published and draft entries such that it' do
      let(:total_entry_count) { 10 }
      let(:published_post_count) { 8 }
      let(:draft_post_count) { total_entry_count - published_post_count }
      let(:entries) do
        build_and_publish_posts published_post_count
        unpublished_posts = bhs_build_example_posts draft_post_count
        unpublished_posts.each(&:save!)
        summarise_blog
      end

      it 'has the correct total number of entries' do
        expect(entries.count).to eq total_entry_count
      end

      it 'has the correct number of draft entries' do
        drafts = entries.reject(&:published?)
        expect(drafts).to have(draft_post_count).entries
      end

      it 'has the draft entries at the start of the summary' do
        drafts = entries.take draft_post_count
        drafts.each { |post| expect(post).not_to be_published }
      end

      it 'has the correct number of published entries' do
        posts = entries.select(&:published?)
        expect(posts).to have(published_post_count).entries
      end

      it 'has the published entries at the end of the summary' do
        posts = entries.drop draft_post_count
        posts.each { |post| expect(post).to be_published }
      end
    end # describe 'includes both published and draft entries such that it'

    it 'sorts the entries in reverse order by pubdate' do
      build_and_publish_posts
      entries = summarise_blog
      last_date = DateTime.now
      entries.each do |post|
        expect(post.pubdate < last_date).to be true
        last_date = post.pubdate
      end
    end

    it 'decorates each PostData entry with a PostDataDecorator' do
      build_and_publish_posts
      entries = summarise_blog
      entries.each do |post|
        expect(post).to be_decorated_with PostDataDecorator
      end
    end
  end # describe 'summarise_blog'
end
