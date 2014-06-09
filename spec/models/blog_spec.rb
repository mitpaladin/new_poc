
require 'spec_helper'

describe Blog do

  subject(:blog) { Blog.new }

  describe 'has accessors for' do

    describe 'a "title" that is' do

      it 'string-like' do
        expect(blog.title).to respond_to :to_s
      end

      it 'not empty' do
        expect(blog.title).to_not be_empty
      end
    end # describe 'a "title" that is'

    describe 'a "subtitle" that is' do

      it 'string-like' do
        expect(blog.subtitle).to respond_to :to_s
      end

      it 'not empty' do
        expect(blog.subtitle).to_not be_empty
      end
    end # describe 'a "subtitle" that is'

    describe 'an "entries" attribute that is' do

      it 'array-like Enumerable' do
        expect(blog.entries).to respond_to :[]
        expect(blog.entries).to be_an Enumerable
      end

      it 'initially empty' do
        expect(blog.entries).to be_empty
      end
    end # describe 'an "entries" attribute that is'
  end # describe 'has accessors for'

  describe :add_entry do

    it 'adds the entry to the blog' do
      entry = Object.new
      blog.add_entry entry
      expect(blog.entries).to include entry
    end
  end # describe :add_entry

  describe :new_post do

    before :each do
      @new_post = OpenStruct.new
      blog.post_source = -> { @new_post }
    end

    it 'returns a new post' do
      expect(blog.new_post).to be @new_post
    end

    it "sets the post's blog reference to itself" do
      expect(blog.new_post.blog).to be blog
    end

    it 'accepts an attribute hash on behalf of the post maker' do
      post_source = double 'post_source'
      params_in = { x: 42, y: 'z' }
      expect(post_source).to receive(:call)
          .with(params_in).and_return @new_post
      blog.post_source = post_source
      blog.new_post x: 42, y: 'z'
    end
  end # describe :new_post
end # describe Blog
