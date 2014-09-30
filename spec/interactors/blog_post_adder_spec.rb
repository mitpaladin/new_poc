
require 'spec_helper'

require 'blog_post_adder'

# Module DSO contains our Domain Service Objects, aka "interactors".
module DSO
  describe BlogPostAdder do

    let(:blog) { Blog.new }
    let(:post) { blog.new_post FactoryGirl.attributes_for(:post_datum) }
    let(:klass) { BlogPostAdder }

    describe 'succeeds when called with a valid Post instance' do

      it 'and returns the (updated) "post" parameter instance' do
        expect(klass.run! post: post).to be post
      end
    end # describe 'succeeds when called with a valid Post instance'

    describe 'reports failure when called with' do

      context 'an invalid Post, by' do
        before :each do
          post.title = nil
        end

        it 'returning false from the #valid? method' do
          expect(klass.run post: post).to_not be_valid
        end

        it 'reporting the correct full error message' do
          # message = "Post Title can't be blank" # See Issue #94.
          message = /\APost Title .+?\z/
          result = klass.run post: post
          expect(result.errors.full_messages).to have(1).item
          expect(result.errors.full_messages.first).to match message
        end
      end # context 'an invalid Post, by'
    end # describe 'fails when called with'

    describe 'supports setting publication status of Post to' do

      context 'draft' do
        let(:actual) { klass.run! post: post, status: 'draft' }

        it 'and adds the post to the blog' do
          expect(blog).to include actual
        end

        it 'and does not publish the post' do
          expect(actual).not_to be_published
        end
      end # context 'draft'

      context 'public' do
        let(:actual) { klass.run! post: post, status: 'public' }

        it 'and adds the post to the blog' do
          expect(blog).to include actual
        end

        it 'and publishes the post' do
          expect(actual).to be_published
        end
      end # context 'public'

      context 'the default status (draft)' do
        let(:actual) { klass.run! post: post }

        it 'and adds the post to the blog' do
          expect(blog).to include actual
        end

        it 'and does not publish the post' do
          expect(actual).not_to be_published
        end
      end # context 'the default status (draft)'
    end # describe 'supports setting publication status of Post to'
  end # describe DSO::BlogPostAdder
end # module DSO
