
require 'spec_helper'

require 'post_publisher'

# Module DSO contains our Domain Service Objects, aka "interactors".
module DSO
  describe PostPublisher do

    let(:blog) { Blog.new }
    let(:post) { blog.new_post title: 'A Title', body: 'A Body' }
    let(:klass) { PostPublisher }

    describe 'succeeds when called with' do

      it 'a valid Post instance' do
        expect { klass.run! post: post }.to_not raise_error
      end
    end # describe 'succeeds when called with'

    describe 'fails when called with' do
      # The problem with validating the post *as a model* vs validating it by
      # scarfing any errors it has is that validation isn't performed in the
      # order we would wish it to be (`model` check first, then method call).
      # Therefore, any passed in "post" that doesn't quack compatibly with
      # ActiveModel::Validations will cause a nasty runtime error. YHBW.

      it 'a Post whose #valid? method returns false' do
        post.title = nil
        expect { klass.run! post: post }.to raise_error
      end
    end # describe 'fails when called with'
  end # describe DSO::PostPublisher
end # module DSO
