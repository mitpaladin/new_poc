
require 'spec_helper'

require_relative 'posts_helper/form_attributes_helper'
require_relative 'posts_helper/status_selection_control'

def new_bhs_build_example_posts(entry_count)
  [].tap do |ret|
    entry_count.times do
      attribs = FactoryGirl.attributes_for :post, author_name: 'John Smith'
      ret.push PostFactory.create(attribs)
    end
  end
end

def new_random_ages(sample, back_to_limit = 180)
  item_maker = -> (_index, current) { current.days.ago }
  RandomItemArrayGenerator.new(back_to_limit).generate sample, item_maker
end

def new_build_and_publish_posts(count = 10)
  ages = new_random_ages(count)
  repo = PostRepository.new
  ret = []
  new_bhs_build_example_posts(count).each_with_index do |post, index|
    attributes = post.attributes.to_hash.merge pubdate: ages[index]
    published_post = post.class.new attributes
    result = repo.add published_post
    ret.push result.entity
  end
  ret
end

describe PostsHelper do
  describe :new_post_form_attributes.to_s do
    subject { helper.new_post_form_attributes }

    it_behaves_like 'a form-attributes helper', 'new_post'

    it 'has a :url item with the value returned from the posts_path helper' do
      expected = helper.posts_path
      expect(subject[:url]).to eq expected
    end
  end # describe :new_post_form_attributes

  describe :edit_post_form_attributes.to_s do
    let(:post_data) { FactoryGirl.create :post }
    subject { helper.send :edit_post_form_attributes, post_data }
    let(:form_name) { 'edit_post' }

    it_behaves_like 'a form-attributes helper', 'edit_post'

    description = 'has a :url item with the value returned from the post_path' \
        ' helper for a specific post'
    it description do
      expected = helper.post_path(post_data)
      expect(subject[:url]).to eq expected
    end
  end # describe :edit_post_form_attributes

  describe :status_select_options.to_s do
    let(:post) { PostFactory.create post_attribs }
    let(:actual) { status_select_options post }
    let(:options) { actual.scan(Regexp.new '<option.+?</option>') }
    let(:selected) { options.select { |s| s.match(/selected\=/) } }

    context 'for an unpublished post' do
      let(:post_attribs) { FactoryGirl.attributes_for :post }

      it_behaves_like 'a status-selection control'

      it 'has "draft" as the selected option' do
        expect(selected.first).to match(/value="draft"/)
      end
    end # context 'for an unpublished post'

    context 'for a published post' do
      let(:post_attribs) { FactoryGirl.attributes_for :post, :published_post }

      it_behaves_like 'a status-selection control'

      it 'has "public" as the selected option' do
        expect(selected.first).to match(/value="public"/)
      end
    end # context 'for a published post'
  end # describe :status_select_options

  describe 'summarise_posts' do
    it 'returns a list of 10 entries by default' do
      @posts = new_build_and_publish_posts 11
      post_entries = summarise_posts
      expect(post_entries.count).to eq 10
    end

    describe 'returns a list of a valid length specified by a parameter' do
      context 'when the specified number of entries exist' do
        [1, 10, 50].each do |entry_count|
          it entry_count.to_s do
            @posts = new_build_and_publish_posts entry_count * 2
            entries = summarise_posts entry_count
            expect(entries.count).to eq entry_count
          end
        end
      end # context 'when the specified number of entries exist'

      context 'when there are fewer than the specified number of entries' do
        it '5' do
          entry_count = Integer(RSpec.current_example.description)
          expected_count = entry_count / 2
          @posts = new_build_and_publish_posts expected_count
          entries = summarise_posts entry_count
          expect(entries.count).to eq expected_count
        end
      end # context 'when there are fewer than the specified number of entries'
    end # describe 'returns a list of a valid length specified by a parameter'

    description = 'includes both published and authored draft entries such' \
        ' that it has the'
    describe description do
      let(:total_entry_count) { 10 }
      let(:published_post_count) { 8 }
      let(:draft_post_count) { total_entry_count - published_post_count }
      let!(:entries) do
        published_posts = new_build_and_publish_posts published_post_count
        unpublished_posts = new_bhs_build_example_posts draft_post_count
        @posts = [unpublished_posts, published_posts].flatten
        summarise_posts
      end
      let(:user) { FactoryGirl.build :user, name: 'John Smith' }

      before :each do
        allow(helper).to receive(:current_user).and_return user
      end

      it 'correct total number of entries' do
        expect(entries.count).to eq total_entry_count
      end

      it 'correct number of draft entries' do
        drafts = entries.reject(&:published?)
        expect(drafts).to have(draft_post_count).entries
      end

      it 'draft entries at the start of the summary' do
        drafts = entries.take draft_post_count
        drafts.each { |post| expect(post).not_to be_published }
      end

      it 'correct number of published entries' do
        posts = entries.select(&:published?)
        expect(posts).to have(published_post_count).entries
      end

      it 'published entries at the end of the summary' do
        posts = entries.drop draft_post_count
        posts.each { |post| expect(post).to be_published }
      end
    end # describe 'includes both published and authored draft entries such...'

    it 'sorts the entries in reverse order by pubdate' do
      @posts = new_build_and_publish_posts
      entries = summarise_posts
      last_date = Time.zone.now
      entries.each do |post|
        expect(post.pubdate < last_date).to be true
        last_date = post.pubdate
      end
      true
    end
  end # describe 'summarise_posts'
end # describe PostsHelper
