
require 'spec_helper'

require 'blog_listing_builder'

# Module DSO contains our Domain Service Objects, aka "interactors".
module DSO
  describe BlogListingBuilder do

    let(:klass) { BlogListingBuilder }

    it 'can be called using a `blog` parameter' do
      blog_obj = Blog.new
      expect { klass.run! blog: blog_obj }.to_not raise_error
    end

    it 'raises an error when no parameter is passed' do
      error = ActiveInteraction::InvalidInteractionError
      message = 'Blog is required'
      expect { klass.run! }.to raise_error error, message
    end

    describe 'copies values from the Blog instance for the' do
      let(:blog)  do
        ret = Blog.new
        post = ret.new_post
        post.title = 'First Title'
        post.body = 'First Body'
        post.publish
        post = ret.new_post
        post.title = 'Second Title'
        post.body = 'Second Body'
        post.publish
        ret
      end

      subject(:obj) { klass.run! blog: blog }

      it 'title' do
        expect(obj.title).to eq blog.title
      end

      it 'subtitle' do
        expect(obj.subtitle).to eq blog.subtitle
      end

      it 'entries' do
        expect(obj.entries.length).to be blog.entries.length
        blog.entries.each_with_index do |entry, index|
          expect(entry.title).to eq obj.entries[index].title
          expect(entry.body).to eq obj.entries[index].body
        end
      end
    end # describe 'copies values from the Blog instance for the'
  end # describe BlogListingBuilder
end # module DSO
