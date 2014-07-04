
require 'spec_helper'

require 'blog_selector'

shared_examples 'array not empty if' do |not_empty|
  if not_empty
    desc = 'returns a non-empty array'
    message = :any?
  else
    desc = 'returns an empty array'
    message = :empty?
  end

  it desc do
    expect(post.error_messages).to be_an Array
    expect(post.error_messages.send message).to be true
  end
end

describe Post do
  let(:blog) { DSO::BlogSelector.run! }
  let(:post) { Post.new FactoryGirl.attributes_for :post_datum }

  context 'initialisation' do

    it 'starts with blank (nil) attributes by default' do
      post = Post.new
      expect(post.title).to be_nil
      expect(post.body).to be_nil
      expect(post.blog).to be_nil
      expect(post.image_url).to be_nil
      expect(post.pubdate).to be_nil
    end

    it 'supports setting attributes in the initialiser' do
      post = Post.new title: 'A Title', body: 'A Body'
      expect(post.title).to eq 'A Title'
      expect(post.body).to eq 'A Body'
    end

    it 'does not support setting arbitrary attributes in the initialiser' do
      post = Post.new title: 'Title', body: 'Body', foo: 'Bar'
      expect(post.instance_variables).to_not include :@foo
    end
  end # context 'initialisation'

  describe 'supports reading and writing' do

    it 'a title' do
      post.title = 'Title'
      expect(post.title).to eq 'Title'
    end

    it 'a post body' do
      post.body = 'The Body'
      expect(post.body).to eq 'The Body'
    end

    it 'the publication date' do
      post.pubdate = Chronic.parse '1 July 2014 at 4.15 PM'
      expect(post.pubdate.to_s).to match(/2014-07-01 16:15:00 [\+\-]\d{4}/)
    end

    it 'supports reading and writing a blog reference' do
      blog = Object.new
      post.blog = blog
      expect(post.blog).to be blog
    end
  end # describe 'supports reading and writing'

  describe :error_messages do

    context 'when called on a valid post' do
      let(:post) { blog.new_post FactoryGirl.attributes_for :post_datum }

      it_behaves_like 'array not empty if', false
      # it 'returns an empty array' do
      #   expect(post.error_messages).to be_an Array
      #   expect(post.error_messages).to be_empty
      # end
    end # context 'when called on a valid post'

    context 'when called on an invalid post' do
      let(:post) do
        blog.new_post FactoryGirl.attributes_for :post_datum, title: nil
      end

      it 'returns a non-empty array' do
        expect(post.error_messages).to be_an Array
        expect(post.error_messages).to_not be_empty
      end

      it 'returns the correct error message in the array' do
        expect(post).to have(1).error_message
        expect(post.error_messages).to include "Title can't be blank"
      end
    end # context 'when called on an invalid post'
  end # describe :error_messages

  describe :publish do
    let(:post) { blog.new_post FactoryGirl.attributes_for :post_datum }

    it 'adds the post to the blog' do
      expect(blog.entry? post).to be false
      post.publish
      expect(blog.entry? post).to be true
    end

    describe 'sets the "pubdate" attribute on a newly-published post' do

      it 'to the current time by default' do
        expect(post.pubdate).to be nil
        stamp = Time.now
        post.publish
        expect(post.pubdate.to_s).to eq stamp.to_s
      end

      it 'to a time specified as a parameter to #publish' do
        stamp = Chronic.parse '1 July 2014 at 4.15 PM'
        post.publish stamp
        expect(post.pubdate.to_s).to eq stamp.to_s
      end
    end # describe 'sets the "pubdate" attribute on a newly-published post'
  end # describe :publish

  describe :published? do

    it 'returns false for a newly-created Post' do
      expect(Blog.new.new_post).to_not be_published
    end

    it 'returns true after a post has been publsihed' do
      post = blog.new_post title: 'A Title', body: 'A Body'
      post.publish
      expect(post).to be_published
    end
  end

  describe :valid? do
    let(:post) { Post.new FactoryGirl.attributes_for(:post_datum) }

    describe 'returns true for a post with' do

      after :each do
        expect(post).to be_valid
      end

      it 'a body and an image URL both present' do
      end

      it 'an empty body and an image URL that is not empty' do
        post.body = ''
      end

      it 'an empty image URL and a body that is not empty' do
        post.image_url = ''
      end
    end # describe 'returns true for a post with'

    describe 'returns false for a post with' do

      after :each do
        expect(post).to_not be_valid
      end

      it 'an empty title' do
        post.title = ''
      end

      it 'both an empty body and an empty image URL' do
        post.body = ''
        post.image_url = ''
      end
    end # describe 'returns false for a post with'
  end # describe :valid?

  describe '<=>' do
    let(:post) { Post.new FactoryGirl.attributes_for(:post_datum) }

    it 'reports two posts as "equal" when they have the same field values' do
      post2 = post.clone
      expect(post2).to eq post
    end

    describe 'reports a post as greater than another if its' do
      let(:post2) { post.clone }

      after :each do
        expect(post2 > post).to be true
      end

      describe "fields compare higher than the other's, when checking" do
        after :each do
          field_sym = (RSpec.current_example.description + '=').to_s
          post.send field_sym, 'string1'
          post2.send field_sym, 'string2'
        end

        it :title do
        end

        it :body do
        end

        it :image_url do
        end
      end # describe "fields compare higher than the other's, when checking"

      describe 'publication date is' do
        it 'more recent than the other' do
          post.pubdate = Chronic.parse 'yesterday at 4 PM'
          post2.pubdate = Chronic.parse 'yesterday at 5 PM'
        end

        it 'set when the other is not' do
          post2.pubdate = Chronic.parse 'yesterday at 5 PM'
        end
      end # describe 'publication date is'
    end # describe 'reports a post as greater than another if its'
  end # describe '<=>'
end # describe Post
