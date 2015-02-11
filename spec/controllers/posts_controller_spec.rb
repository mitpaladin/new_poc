
require 'spec_helper'

require_relative 'posts_controller/an_attempt_to_create_an_invalid_post'
require_relative 'posts_controller/an_unauthorised_user_for_this_post'

# Posts controller dispatches post-specific actions
describe PostsController do
  let(:identity) { CurrentUserIdentity.new session }

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
    let(:author) { FactoryGirl.create :user, :saved_user }
    let(:public_post_count) { 6 }
    let(:draft_post_count) { 4 }
    let!(:draft_posts) do
      FactoryGirl.create_list :post, draft_post_count, :saved_post,
                              author_name: author.name
    end
    let!(:public_posts) do
      FactoryGirl.create_list :post, public_post_count, :saved_post,
                              :published_post
    end

    describe 'does the basics:' do
      before :each do
        _ = [public_posts, draft_posts]
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
        @posts.each_with_index do |post, index|
          expect(post).to be_saved_post_entity_for public_posts[index]
        end
      end
    end # context 'for the guest user'

    context 'for a registered user owning no draft posts' do
      before :each do
        user = FactoryGirl.create :user, :saved_user
        identity.current_user = user
        get :index
        @posts = assigns[:posts]
      end

      it 'assigns only the public posts to :posts' do
        expect(@posts).to have(public_post_count).entries
        @posts.each_with_index do |post, index|
          expect(post).to be_saved_post_entity_for public_posts[index]
        end
      end
    end # context 'for a registered user owning no draft posts'

    context 'for a registered user owning draft posts' do
      before :each do
        identity.current_user = author
        get :index
        @posts = assigns[:posts]
      end

      it 'assigns all public posts and drafts by the current user to :posts' do
        expected_count = public_post_count + draft_post_count
        expect(@posts).to have(expected_count).entries
        draft_posts.each_with_index do |post, index|
          expect(@posts[index]).to be_saved_post_entity_for post
        end
        public_posts.each_with_index do |post, index|
          post_index = index + draft_post_count
          expect(@posts[post_index]).to be_saved_post_entity_for post
        end
      end
    end # context 'for a registered user owning no draft posts'
  end # describe "GET 'index'" (StoreResult removed)

  describe "GET 'new'" do
    context 'for a Registered User' do
      before :each do
        user = FactoryGirl.create :user, :saved_user
        identity.current_user = user
        get :new
      end

      it 'returns http success' do
        expect(response).to be_success
      end

      it 'assigns a new Newpoc::Entity::Post instance to :post' do
        post = assigns[:post]
        expect(post).to be_a Newpoc::Entity::Post
        expect(post).not_to be_persisted
      end

      it 'renders the :new template' do
        expect(response).to render_template :new
      end
    end # context 'for a Registered User'

    context 'for the Guest User' do
      before :each do
        get :new
      end

      it 'does not assign a :post variable' do
        expect(assigns).not_to have_key :post
      end

      it 'redirects to the landing page' do
        expect(response).to redirect_to root_path
      end

      it 'renders the correct flash error message' do
        expect(flash[:alert]).to eq 'Not logged in as a registered user!'
      end
    end # context 'for the Guest User'
  end # describe "GET 'new'" (StoreResult removed)

  describe "POST 'create'" do
    let(:params) do
      attrs = FactoryGirl.attributes_for :post
      attrs[:author_name] = identity.current_user
      [:pubdate, :slug].each { |attr| attrs.delete attr }
      attrs
    end

    context 'for a Registered User' do
      before :each do
        user = FactoryGirl.create :user, :saved_user
        identity.current_user = user
      end

      describe 'with valid parameters' do
        before :each do
          post :create, post_data: params
        end

        it 'assigns the :post item as a Newpoc::Entity::Post instance' do
          expect(assigns[:post]).to be_a Newpoc::Entity::Post
        end

        it 'persists the PostDao instance corresponding to the :post' do
          post = assigns[:post]
          expect(post).to be_persisted
          dao = PostDao.find_by_slug post.slug
          [:body, :image_url, :slug, :title].each do |attrib|
            expect(post.attributes[attrib]).to eq dao[attrib]
          end
          [:created_at, :updated_at].each do |attrib|
            expect(post.attributes[attrib]).to be_within(0.5.seconds)
              .of dao[attrib]
          end
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
        post :create, post_data: params
      end

      it 'does not assign a value to the :post item' do
        expect(assigns).not_to have_key :post
      end

      it 'redirects to the root path' do
        expect(response).to redirect_to root_path
      end

      it 'renders the correct flash alert message' do
        expected = 'Not logged in as a registered user!'
        expect(flash[:alert]).to eq expected
      end
    end # context 'for the Guest User'
  end # describe "POST 'create'" (StoreResult removed)

  describe "GET 'edit'" do
    let(:author) { FactoryGirl.create :user, :saved_user }
    let!(:post) do
      FactoryGirl.create :post, :saved_post, :published_post,
                         author_name: author.name
    end

    context 'for the Guest User' do
      before :each do
        get :edit, id: post.slug
      end

      expected = 'Not logged in as a registered user!'
      it_behaves_like 'an unauthorised user for this post', expected
    end # context 'for the Guest User'

    context 'when a user other than the post author is logged in' do
      let(:user) { FactoryGirl.create :user, :saved_user }

      before :each do
        identity.current_user = user
        get :edit, id: post.slug
      end

      message = 'User J Random User Number .+? is not the author of this post!'
      it_behaves_like 'an unauthorised user for this post', message
    end # context 'when a user other than the post author is logged in'

    context 'when the logged-in user is the post author' do
      before :each do
        identity.current_user = author
        get :edit, id: post.slug
      end

      it 'returns an HTTP status code of OK' do
        expect(response).to be_ok
      end

      it 'renders the "edit" template' do
        expect(response).to render_template 'edit'
      end

      it 'assigns the :post variable' do
        assigned = assigns[:post]
        [:body, :image_url, :slug, :title].each do |attrib|
          expect(assigned.attributes[attrib]).to eq post[attrib]
        end
        expect(assigned[:pubdate]).to be_within(0.5.seconds).of post[:pubdate]
      end
    end # context 'when the logged-in user is the post author'
  end # describe "GET 'edit'" (StoreResult removed)

  describe "GET 'show'" do
    let(:author) { FactoryGirl.create :user, :saved_user }

    context 'for a valid public post' do
      let(:article) do
        FactoryGirl.create :post, :saved_post, :published_post,
                           author_name: author.name
      end

      before :each do
        get :show, id: article.slug
      end

      it 'responds with an HTTP status of :ok' do
        expect(response).to be_ok
      end

      it 'assigns an object to Post' do
        expect(assigns[:post]).to be_a Newpoc::Entity::Post
        expect(assigns[:post].title).to eq article.title
      end

      it 'renders the :show template' do
        expect(response).to render_template :show
      end
    end # context 'for a valid public post'

    context 'for a draft post' do
      let(:article) do
        FactoryGirl.create :post, :saved_post, author_name: author.name
      end

      context 'by the current user' do
        before :each do
          identity.current_user = author
          get :show, id: article.slug
        end

        it 'responds with an HTTP status of :ok' do
          expect(response).to be_ok
        end

        it 'assigns an object to Post' do
          expect(assigns[:post]).to be_a Newpoc::Entity::Post
          expect(assigns[:post].title).to eq article.title
        end

        it 'renders the :show template' do
          expect(response).to render_template :show
        end
      end # context 'by the current user

      context 'by a different user' do
        let(:user) do
          Newpoc::Entity::User.new FactoryGirl.attributes_for :user, :saved_user
        end

        before :each do
          identity.current_user = user
          get :show, id: article.slug
        end

        it 'responds with an HTTP redirect' do
          expect(response).to be_redirect
        end

        it 'redirects to the landing page' do
          expect(response).to redirect_to root_path
        end

        it 'renders the correct flash error message' do
          expected = "Cannot find post identified by slug: '#{article.slug}'!"
          expect(flash[:alert]).to eq expected
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

      it 'redirects to the landing page' do
        expect(response).to redirect_to root_path
      end

      it 'renders the correct flash error message' do
        expected = "Cannot find post identified by slug: '#{bad_slug}'!"
        expect(flash[:alert]).to eq expected
      end
    end # context 'for an invalid post'
  end # describe "GET 'show'" (StoreResult removed)

  describe "PATCH 'update'" do
    let(:author) { FactoryGirl.create :user, :saved_user }

    context 'when the post status is unaffected' do
      let(:post) do
        FactoryGirl.create :post, :saved_post, :published_post,
                           author_name: author.name
      end
      let(:post_data) { { body: 'Updated ' + post.body } }

      context 'for the post author' do
        before :each do
          identity.current_user = author
        end

        context 'with valid post data' do
          before :each do
            patch :update, id: post.slug, post_data: post_data
          end

          it 'redirects to the post page' do
            expect(response).to redirect_to post_path(post)
          end

          it 'assigns the updated post' do
            actual = assigns[:post]
            expect(actual.body).to eq post_data[:body]
            comparison_keys = [:author_name, :imaage_url, :slug, :title]
            comparison_keys.each do |attrib_key|
              expect(actual.attributes[attrib_key]).to eq post[attrib_key.to_s]
            end
            comparison_keys = [:pubdate, :created_at]
            comparison_keys.each do |attrib_key|
              expect(actual.attributes[attrib_key])
                .to be_within(0.5.seconds).of post[attrib_key]
            end
          end
        end # context 'with valid post data'

        context 'with invalid post data' do
          before :each do
            data = { body: '', image_url: '' }
            # identity.current_user = author
            patch :update, id: post.slug, post_data: data
          end

          it 'redirects to the root path' do
            expect(response).to redirect_to root_path
          end

          it 'assigns no :post' do
            expect(assigns).not_to have_key :post
          end

          fit 'has the correct flash message' do
            expected = 'Body must be specified if image URL is omitted'
            expect(flash[:alert]).to eq expected
          end
        end # context 'with invalid post data'
      end # context 'for the post author'

      context 'for a registered user other than the post author' do
        before :each do
          user = FactoryGirl.create :user, :saved_user
          identity.current_user = user
          patch :update, id: post.slug, post_data: post_data
        end

        it_behaves_like 'an unauthorised user for this post'
      end # context 'for a registered user other than the post author'

      context 'for the Guest User' do
        before :each do
          patch :update, id: post.slug, post_data: post_data
        end

        message = 'Not logged in as a registered user!'
        it_behaves_like 'an unauthorised user for this post', message
      end # context 'for the Guest User'
    end # context 'when the post status is unaffected'

    context 'for an existing draft post' do
      let(:post) do
        FactoryGirl.create :post, :saved_post,
                           author_name: author.name
      end

      it 'that publishes the post' do
        post_data = { pubdate: Time.now }
        identity.current_user = author
        expect(post.pubdate).to be nil  # draft, unpublished
        patch :update, id: post.slug, post_data: post_data
        expect(assigns[:post]).to be_published
        expect(assigns[:post]).not_to be_draft
      end
    end # context 'for an existing draft post'

    context 'for an existing public post' do
      let(:post) do
        FactoryGirl.create :post, :saved_post, :published_post,
                           author_name: author.name
      end

      it 'that updates the post status to "draft"' do
        post_data = { pubdate: nil }
        identity.current_user = author
        patch :update, id: post.slug, post_data: post_data
        expect(assigns[:post]).to be_draft
      end
    end # context 'for an existing public post'
  end # describe "PATCH 'update'"
end # describe PostsController
