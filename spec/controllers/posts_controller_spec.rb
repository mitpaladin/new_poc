
require 'spec_helper'

require_relative 'posts_controller/an_attempt_to_create_an_invalid_post'
require_relative 'posts_controller/an_unauthorised_user_for_this_post'

# Posts controller dispatches post-specific actions
describe PostsController do
  describe :routing.to_s, type: :routing do
    it { expect(get posts_path).to route_to 'posts#index' }
    it { expect(get new_post_path).to route_to 'posts#new' }
    it { expect(post posts_path).to route_to 'posts#create' }
    it do
      expect(get post_path('the-title'))
        .to route_to controller: 'posts', action: 'show', id: 'the-title'
    end
    # Can't disable ID-based routing but enable slug-based. This has to be
    # restricted at the controller/DSO level.
    # it { expect(get '/posts/:id').to_not be_routable }
    it do
      expect(get edit_post_path('the-title'))
        .to route_to controller: 'posts', action: 'edit', id: 'the-title'
    end
    it do
      expect(put post_path 'the-title')
        .to route_to controller: 'posts', action: 'update', id: 'the-title'
    end
    it { expect(delete post_path(1)).to_not be_routable }
  end

  describe :helpers.to_s do
    it { expect(posts_path).to eq '/posts' }
    it { expect(new_post_path).to eq '/posts/new' }
    it { expect(posts_path).to eq '/posts' }
    it { expect(post_path(42)).to eq '/posts/42' }
  end

  describe "GET 'index'" do
    let(:author) { FactoryGirl.create :user_datum }
    let(:public_post_count) { 6 }
    let(:draft_post_count) { 4 }
    let!(:draft_posts) do
      FactoryGirl.create_list :post_datum, draft_post_count, :saved_post,
                              :draft_post, author_name: author.name
    end
    let!(:public_posts) do
      FactoryGirl.create_list :post_datum, public_post_count, :saved_post,
                              :public_post
    end

    describe 'does the basics:' do
      before :each do
        get :index
        @posts = assigns[:posts]
      end

      it 'returns http success' do
        expect(response).to be_success
      end

      it 'assigns the :posts variable' do
        expect(@posts).not_to be nil
      end

      it 'renders the index template' do
        expect(response).to render_template 'index'
      end
    end # describe 'does the basics:'

    context 'for the guest user' do
      before :each do
        get :index
        @posts = assigns[:posts]
      end

      it 'assigns only the public posts to :posts' do
        expect(@posts).to have(public_post_count).entries
        @posts.each do |post|
          expect(public_posts).to include post
        end
      end
    end # context 'for the guest user'

    context 'for a registered user owning no draft posts' do
      before :each do
        user = FactoryGirl.create :user_datum
        session[:user_id] = user.id
        get :index
        @posts = assigns[:posts]
      end

      it 'assigns only the public posts to :posts' do
        expect(@posts).to have(public_post_count).entries
        @posts.each do |post|
          expect(public_posts).to include post
        end
      end
    end # context 'for a registered user owning no draft posts'

    context 'for a registered user owning draft posts' do
      before :each do
        session[:user_id] = author.id
        get :index
        @posts = assigns[:posts]
      end

      it 'assigns all public posts and drafts by the current user to :posts' do
        expected_count = public_post_count + draft_post_count
        expect(@posts).to have(expected_count).entries
        public_posts.each do |post|
          expect(@posts).to include post
        end
        draft_posts.each do |post|
          expect(@posts).to include post
        end
      end
    end # context 'for a registered user owning no draft posts'
  end # describe "GET 'index'"

  describe "GET 'new'" do

    context 'for a Registered User' do
      before :each do
        @user = FactoryGirl.create :user_datum
        session[:user_id] = @user.id
        get :new
      end

      after :each do
        session[:user_id] = nil
        @user.destroy
      end

      it 'returns http success' do
        expect(response).to be_success
      end

      it 'assigns a new PostData instance to :post' do
        post = assigns[:post]
        expect(post).to be_a PostData
        expect(post).to be_a_new_record
      end

      it 'renders the :new template' do
        expect(response).to render_template :new
      end
    end # context 'for a Registered User'

    context 'for the Guest User' do
      before :each do
        session[:user_id] = nil
        get :new
      end

      it 'assigns a new PostData instance to :post' do
        expect(assigns[:post]).to be_a_new_record
      end

      it 'redirects to the landing page' do
        expect(response).to be_redirection
        expect(response).to redirect_to root_path
      end

      it 'renders the correct flash error message' do
        expected = 'You are not authorized to perform this action.'
        expect(flash[:error]).to eq expected
      end
    end # context 'for the Guest User'
  end # describe "GET 'new'"

  describe "POST 'create'" do
    let(:params) { FactoryGirl.attributes_for :post_datum }

    context 'for a Registered User' do
      describe 'with valid parameters' do
        before :each do
          @user = FactoryGirl.create :user_datum
          session[:user_id] = @user.id
          post :create, post_data: params
        end

        after :each do
          session[:user_id] = nil
          @user.destroy
        end

        it 'assigns the :post item as a PostData instance' do
          expect(assigns[:post]).to be_a PostData
        end

        it 'persists the PostData instance corresponding to the :post' do
          expect(assigns[:post]).to_not be_a_new_record
        end

        it 'redirects to the root path' do
          expect(response).to redirect_to root_path
        end

        it 'displays the "Post added!" flash message' do
          expect(request.flash[:success]).to eq 'Post added!'
        end
      end # describe 'with valid parameters'

      it_behaves_like 'an attempt to create an invalid Post'
    end # context 'for a Registered User'

    context 'for the Guest User' do
      before :each do
        session[:user_id] = nil
      end

      describe 'with valid parameters' do
        before :each do
          post :create, post_data: params
        end

        it 'assigns the :post item as a new PostData instance' do
          post = assigns[:post]
          expect(post).to be_a PostData
          expect(post).to be_a_new_record
        end

        it 'redirects to the root path' do
          expect(response).to redirect_to root_path
        end

        it 'renders the correct flash error message' do
          expected = 'You are not authorized to perform this action.'
          expect(flash[:error]).to eq expected
        end
      end # describe 'with valid parameters'

      it_behaves_like 'an attempt to create an invalid Post'
    end # context 'for the Guest User'
  end # describe "POST 'create'"

  describe "GET 'edit'" do
    let(:author) { FactoryGirl.create :user_datum }
    let!(:post) do
      FactoryGirl.create(:post_datum, author_name: author.name).decorate
    end

    context 'for the Guest User' do
      before :each do
        get :edit, id: post.slug
      end

      it_behaves_like 'an unauthorised user for this post'
    end # context 'for the Guest User'

    context 'when a user other than the post author is logged in' do
      let(:user) { FactoryGirl.create :user_datum }

      before :each do
        session[:user_id] = user.id
        get :edit, id: post.slug
      end

      it_behaves_like 'an unauthorised user for this post'
    end # context 'when a user other than the post author is logged in'

    context 'when the logged-in user is the post author' do
      before :each do
        session[:user_id] = author.id
        get :edit, id: post.slug
      end

      it 'returns an HTTP status code of OK' do
        expect(response).to be_ok
      end

      it 'renders the "edit" template' do
        expect(response).to render_template 'edit'
      end

      it 'assigns the :post variable' do
        expect(assigns[:post]).to eq post.decorate
      end
    end # context 'when the logged-in user is the post author'
  end # describe "GET 'edit'"

  describe "GET 'show'" do
    let(:author) { FactoryGirl.create :user_datum }

    context 'for a valid public post' do
      let(:article) do
        FactoryGirl.create :post_datum, :saved_post, :public_post,
                           author_name: author.name
      end

      before :each do
        get :show, id: article.slug
      end

      it 'responds with an HTTP status of :ok' do
        expect(response).to be_ok
      end

      it 'assigns an object to Post' do
        expect(assigns[:post]).to be_a PostData
      end

      it 'renders the :show template' do
        expect(response).to render_template :show
      end
    end # context 'for a valid public post'

    context 'for a draft post' do
      context 'by the current user' do
        let(:article) do
          FactoryGirl.create :post_datum, :saved_post, :draft_post,
                             author_name: author.name
        end

        before :each do
          session[:user_id] = author.id
          get :show, id: article.slug
        end

        it 'responds with an HTTP status of :ok' do
          expect(response).to be_ok
        end

        it 'assigns an object to Post' do
          expect(assigns[:post]).to be_a PostData
        end

        it 'renders the :show template' do
          expect(response).to render_template :show
        end
      end # context 'by the current user

      context 'by a different user' do
        let(:article) do
          FactoryGirl.create :post_datum, :saved_post, :draft_post
        end
        let(:user) { FactoryGirl.create :user_datum }

        before :each do
          session[:user_id] = user.id
          get :show, id: article.slug
        end

        it 'responds with an HTTP redirect' do
          expect(response).to be_redirect
        end

        it 'redirects to the root URL' do
          expect(response).to redirect_to root_url
        end

        it 'renders the correct flash error message' do
          expected = 'You are not authorized to perform this action.'
          expect(flash[:error]).to eq expected
        end
      end
    end # context 'for a draft post'

    context 'for an invalid post' do
      let(:bad_slug) { 'this-is-a-bogus-article-slug' }
      before :each do
        get :show, id: bad_slug
      end

      it 'responds with an HTTP status of :redirect' do
        expect(response).to be_redirect
      end

      it 'redirects to the root URL' do
        expect(response).to redirect_to root_url
      end

      it 'renders the correct flash error message' do
        expected = [
          'There is no article with an ID of "',
          '"!'].join bad_slug
        expect(flash[:alert]).to eq expected
      end
    end # context 'for an invalid post'
  end # describe "GET 'show'"

  describe "PATCH 'update'" do
    let(:author) { FactoryGirl.create :user_datum }

    context 'when the post status is unaffected' do
      let(:post) do
        FactoryGirl.create(:post_datum, author_name: author.name).decorate
      end
      let(:post_data) { { body: 'Updated ' + post.body } }

      context 'for the post author' do
        before :each do
          session[:user_id] = author.id
          patch :update, id: post.slug, post_data: post_data
        end

        it 'redirects to the post page' do
          expect(response).to redirect_to post_path(post)
        end

        it 'assigns the updated post' do
          actual = assigns[:post]
          expect(actual).to eq post
          expect(actual.body).to eq post_data[:body]
        end
      end # context 'for the post author'

      context 'for a registered user other than the post author' do
        before :each do
          user = FactoryGirl.create :user_datum
          session[:user_id] = user.id
          patch :update, id: post.slug, post_data: post_data
        end

        it_behaves_like 'an unauthorised user for this post'
      end # context 'for a registered user other than the post author'

      context 'for the Guest User' do
        before :each do
          patch :update, id: post.slug, post_data: post_data
        end

        it_behaves_like 'an unauthorised user for this post'
      end # context 'for the Guest User'
    end # context 'when the post status is unaffected'

    context 'for an existing draft post' do
      let(:post) do
        FactoryGirl.create(:post_datum,
                           :draft_post,
                           :saved_post,
                           author_name: author.name
          ).decorate
      end

      it 'that updates the post status to "public"' do
        post_data = { post_status: 'public' }
        session[:user_id] = author.id
        patch :update, id: post.slug, post_data: post_data
        expect(assigns[:post].post_status).to eq 'public'
      end
    end # context 'for an existing draft post'

    context 'for an existing public post' do
      let(:post) do
        FactoryGirl.create(:post_datum,
                           :public_post,
                           :saved_post,
                           author_name: author.name
          ).decorate
      end

      it 'that updates the post status to "draft"' do
        post_data = { post_status: 'draft' }
        session[:user_id] = author.id
        patch :update, id: post.slug, post_data: post_data
        expect(assigns[:post].post_status).to eq 'draft'
      end
    end # context 'for an existing public post'
  end # describe "PATCH 'update'"
end # describe PostsController
