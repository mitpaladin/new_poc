
require 'spec_helper'

shared_examples 'a form-attributes helper' do |form_name|
  describe ":#{form_name}_form_attributes" do
    it 'returns a Hash' do
      expect(subject).to be_a Hash
    end

    describe 'has top-level keys for' do
      [:html, :role, :url].each do |key|
        it ":#{key}" do
          expect(subject).to have_key key
        end
      end
    end # describe 'has top-level keys for'

    describe 'has an :html sub-hash that contains the correct values for' do
      it 'the :id key' do
        expect(subject[:html][:id]).to eq form_name
      end

      it 'the :class key' do
        classes = subject[:html][:class].split(/\s+/)
        expect(classes).to include 'form-horizontal'
        expect(classes).to include form_name
      end
    end # describe 'has an :html sub-hash that contains the correct values for'

    it 'has a :role item with the value "form" as an ARIA instruction' do
      expect(subject[:role]).to eq 'form'
    end
  end # describe ":#{form_name}_form_attributes"
end

shared_examples 'a status-selection control' do
  it 'returns two HTML <option> tags' do
    expect(options.count).to eq 2
  end

  describe 'returns <option> tags for' do
    %w(draft public).each do |status|
      it status do
        regex = Regexp.new "value=\"#{status}\""
        match = options.select { |s| s.match regex }
        expect(match).not_to be nil
      end
    end
  end # describe 'returns <option> tags for'
end

def new_bhs_build_example_posts(entry_count)
  ret = []
  entry_count.times do
    attribs = FactoryGirl.attributes_for :post, author_name: 'John Smith'
    ret.push Newpoc::Entity::Post.new(attribs)
  end
  ret
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
    attributes = post.attributes.merge pubdate: ages[index]
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
    let(:post) { Newpoc::Entity::Post.new post_attribs }
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
        ' that it'
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
    end # describe 'includes both published and authored draft entries such...'

    it 'sorts the entries in reverse order by pubdate' do
      @posts = new_build_and_publish_posts
      entries = summarise_posts
      last_date = DateTime.now
      entries.each do |post|
        expect(post.pubdate < last_date).to be true
        last_date = post.pubdate
      end
      true
    end
  end # describe 'summarise_posts'

  describe 'build_body' do
    let(:actual) { build_body post }

    context 'for a text post' do
      let(:post) { FactoryGirl.build :post }

      it 'returns the post body wrapped in an HTML :p tag pair' do
        expected = ['<p>', '</p>'].join post.body
        expect(actual).to eq expected
      end
    end

    context 'for an image post' do
      let(:post) { FactoryGirl.build :post, :image_post }

      it 'returns an HTML fragment wrapped in an outer :figure tag pair' do
        expect(actual).to match(/<figure>.+<\/figure>/m)
      end

      it 'contains the image URL within an :img tag' do
        expect(actual).to match(/<img src="#{post.image_url}">/)
      end

      it 'contains the post body wrapped in a :figcaption tag pair' do
        expected = %r{<figcaption><p>#{post.body}</p></figcaption}m
        expect(actual).to match expected
      end
    end
  end # describe 'build_body'
end # describe PostsHelper
