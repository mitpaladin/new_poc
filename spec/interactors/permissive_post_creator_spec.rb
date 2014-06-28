
require 'spec_helper'

require 'permissive_post_creator'

# Domain-service objects should live in a module within Blog.
module DSO
  describe PermissivePostCreator do

    let(:klass) { PermissivePostCreator }
    let(:blog) { {} }
    let(:post_data) { { title: 'This is a Title', body: 'This is a Body' } }
    let(:full_params) { { blog: blog, post_data: post_data } }
    let(:image_url) do
      'http://images.nationalgeographic.com/wpf/media-live/photos/000/805/' \
          'cache/waterfall-canyon-gorge-oregon_80569_990x742.jpg'
    end
    let(:image_post_params) { post_data.merge(image_url: image_url) }

    it 'ignores a missing "blog" input parameter and Does The Right Thing' do
      post = klass.run! post_data: post_data
      expect(post).to be_a Post
      expect(post).to_not respond_to :id
    end

    describe 'succeeds when called without parameters, so that it' do

      it 'creates a text post with an empty title and an empty body' do
        post = klass.run!
        expect(post).to be_a Post
        expect(post.title).to be_empty
        expect(post.body).to be_empty
      end
    end # describe 'succeeds when called without parameters, so that it'

    describe 'succeeds when called with valid parameters for' do

      describe 'a text post, so that it' do
        it 'is valid' do
          expect(klass.run! full_params).to be_valid
        end

        it 'has a reference to the blog' do
          blog_entity = DSO::BlogSelector.run! params: { blog_params: blog }
          post = klass.run! full_params
          expect(post.blog).to have_same_blog_content_as blog_entity
        end
      end # describe 'a text post, so that it'

      describe 'an image post, so that it' do
        it 'is valid' do
          expect(klass.run! blog: blog,
                            post_data: image_post_params).to be_valid
        end

        it 'has a reference to the blog' do
          blog_entity = DSO::BlogSelector.run! params: { blog_params: blog }
          post = klass.run! blog: blog, params_in: image_post_params
          expect(post.blog).to have_same_blog_content_as blog_entity
        end
      end # describe 'an image post, so that it'
    end # describe 'succeeds when called with valid parameters for'

    it 'succeeds but marks post as invalid given invalid parameters' do
      missing_title_params = image_post_params
      missing_title_params.delete :title
      post = klass.run! blog: blog, post_data: missing_title_params
      expect(post).to_not be_valid
    end
  end # describe DSO::PermissivePostCreator
end # module DSO
