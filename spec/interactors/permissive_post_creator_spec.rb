
require 'spec_helper'

require 'permissive_post_creator'

# Domain-service objects should live in a module within Blog.
module DSO
  describe PermissivePostCreator do

    let(:klass) { PermissivePostCreator }
    let(:blog) { {} }
    let(:valid_params) do
      { post_data: { title: 'This is a Title', body: 'This is a Body' } }
    end
    let(:missing_title_params) do
      { post_data: { title: '', body: 'This is a Body' } }
    end

    it 'ignores an invalid "blog" input parameter and Does The Right Thing' do
      call_params = { blog: Object.new.to_param, params_in: valid_params }
      post = klass.run! call_params
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
          expect(klass.run! blog: blog, params_in: valid_params).to be_valid
        end

        it 'has a reference to the blog' do
          blog_entity = DSO::BlogSelector.run! params: { blog_params: blog }
          post = klass.run! blog: blog, params_in: valid_params
          expect(post.blog).to have_same_blog_content_as blog_entity
        end
      end # describe 'a text post, so that it'
    end # describe 'succeeds when called with valid parameters for'

    it 'succeeds but marks post as invalid given invalid parameters' do
      post = klass.run! blog: blog, params_in: missing_title_params
      expect(post).to_not be_valid
    end
  end # describe DSO::PermissivePostCreator
end # module DSO
