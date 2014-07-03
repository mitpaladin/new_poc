
require 'spec_helper'

require 'placeholder_builder'

# Module DSO contains our Domain Service Objects, aka "interactors".
module DSO
  describe PlaceholderBuilder do

    let(:blog) { Blog.new }

    describe 'can be executed by passing in the blog as a parameter' do

      it 'reporting a successful outcome' do
        expect(PlaceholderBuilder.run blog: blog).to be_valid
      end

    end # describe 'can be executed by passing in the blog as a parameter'

    describe 'updates the blog contents' do

      it 'to have two new posts' do
        expect(blog).to have(0).entries
        PlaceholderBuilder.run! blog: blog
        expect(blog).to have(2).entries
      end

      describe 'with expected values for the' do
        before :each do
          PlaceholderBuilder.run! blog: blog
        end

        after :each do
          expect(@post.title).to eq @title
          expect(@post.body).to eq @body
        end

        it 'first post' do
          @post = blog.entries.first
          @title = 'Paint just applied'
          @body = "Paint just applied. It's a lovely orangey-purple!"
        end

        it 'second post' do
          @post = blog.entries.second
          @title = 'Still wet'
          @body = 'Paint is still quite wet. No bubbling yet!'
        end
      end # describe 'with expected values for the'
    end # describe 'updates the blog contents'
  end # describe DSO::PlaceholderBuilder
end # module DSO
