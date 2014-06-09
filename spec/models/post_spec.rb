
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
    expect { Post.new title: 'Title', body: 'Body', foo: 'Bar' }.to \
        raise_error NoMethodError, /undefined method `foo=' .+/
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

    it 'adds the post to the blog' do
      blog = Blog.new
      post.blog = blog
      expect(blog.entries).to_not include post
      post.publish
      expect(blog.entries).to include post
    end
  end # describe :publish
end # describe Post
