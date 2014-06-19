
require 'spec_helper'

describe Post do
  let(:post) { Post.new }

  it 'starts with blank (nil) attributes' do
    expect(post.title).to be_nil
    expect(post.body).to be_nil
    expect(post.blog).to be_nil
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

  describe 'supports reading and writing' do

    it 'a title' do
      post.title = 'Title'
      expect(post.title).to eq 'Title'
    end

    it 'a post body' do
      post.body = 'The Body'
      expect(post.body).to eq 'The Body'
    end

    it 'supports reading and writing a blog reference' do
      blog = Object.new
      post.blog = blog
      expect(post.blog).to be blog
    end
  end # describe 'supports reading and writing'

  describe :publish do
    let(:post) { Post.new title: 'A Title' }

    it 'adds the post to the blog' do
      blog = Blog.new
      post.blog = blog
      expect(blog.entry? post).to be false
      post.publish
      expect(blog.entry? post).to be true
    end
  end # describe :publish

  describe :valid? do
    let(:post) { Post.new title: 'A Title' }

    it 'returns true for a valid post' do
      expect(post).to be_valid
    end

    it 'returns false for an invalid post' do
      post.title = ''
      expect(post).to_not be_valid
    end
  end # describe :valid?

  describe 'supports ActiveModel conventions by' do

    subject(:post) { Blog.new.new_post FactoryGirl.attributes_for(:post_datum) }

    describe 'including module ActiveModel::Conversion module, as shown by' do

      it 'having a #to_model instance method' do
        expect(post).to respond_to :to_model
      end

    end # describe 'including module ActiveModel::Conversion, as shown by'

    describe 'extending module ActiveModel::Naming, as shown by' do

      it 'having a #model_name class method' do
        expect(post.class).to respond_to :model_name
      end

    end # describe 'extending module ActiveModel::Naming, as shown by'
  end # describe 'supports ActiveModel conventions by'
end # describe Post
