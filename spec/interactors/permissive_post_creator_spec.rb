
require 'spec_helper'

require 'permissive_post_creator'

# Domain-service objects should live in a module within Blog.
module DSO
  describe PermissivePostCreator do

    let(:klass) { PermissivePostCreator }
    let(:blog) { Blog.new }
    let(:valid_params) do
      { post_data: { title: 'This is a Title', body: 'This is a Body' } }
    end
    let(:image_post_params) do
      { post_data: {
        title: 'This is a Title',
        image_url: 'http://localhost/foo.png'
      } }
    end

    it 'fails when called with an invalid Blog parameter' do
      call_params = { blog: Object.new, params_in: valid_params }
      expect { klass.run! call_params }.to raise_error(
        ActiveInteraction::InvalidInteractionError,
        'Blog is not a valid interface'
        )
    end

    describe 'succeeds when called with valid parameters for' do

      describe 'a text post, so that it' do
        it 'is valid' do
          expect(klass.run! blog: blog, params_in: valid_params).to be_valid
        end

        it 'has a reference to the blog' do
          post = klass.run! blog: blog, params_in: valid_params
          expect(post.blog).to be blog
        end
      end # describe 'a text post, so that it'

      describe 'an image post, so that it' do
        it 'is valid' do
          expect(klass.run! blog: blog,
                            params_in: image_post_params).to be_valid
        end

        it 'has a reference to the blog' do
          post = klass.run! blog: blog, params_in: image_post_params
          expect(post.blog).to be blog
        end
      end # describe 'an image post, so that it'
    end # describe 'succeeds when called with valid parameters for'
  end # describe DSO::PermissivePostCreator
end # module DSO
