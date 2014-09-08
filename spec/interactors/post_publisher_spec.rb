
require 'spec_helper'

require 'post_publisher'

# Module DSO contains our Domain Service Objects, aka "interactors".
module DSO
  describe PostPublisher do

    let(:blog) { Blog.new }
    let(:post) { blog.new_post FactoryGirl.attributes_for(:post_datum) }
    let(:klass) { PostPublisher }

    describe 'succeeds when called with' do

      it 'a valid Post instance' do
        expect { klass.run! post: post }.to_not raise_error
      end
    end # describe 'succeeds when called with'

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
  end # describe DSO::PostPublisher
end # module DSO
