
require 'spec_helper'

shared_examples 'an attempt to create an invalid Post' do
  describe 'with an invalid title, the returned PostData instance is' do

    before :each do
      params[:title] = ''
      post :create, post_data: params, blog: blog
      @post = assigns[:post]
    end

    it 'a new record' do
      expect(@post).to be_a_new_record
    end

    it 'is invalid' do
      expect(@post).to_not be_valid
    end

    it 'provides the correct error message' do
      expect(@post.errors.full_messages).to include "Title can't be blank"
    end
  end # describe 'with an invalid title, the returned PostData instance is'
end # shared_examples 'an attempt to create an invalid Post'

# Posts controller dispatches post-specific actions
describe PostsController do
  describe :routing.to_s, type: :routing do
    it { expect(get '/posts/new').to route_to 'posts#new' }
    it { expect(post '/posts').to route_to 'posts#create' }
    it { expect(get '/posts').to_not be_routable }
    it { expect(get '/posts/1').to_not be_routable }
    it { expect(get '/posts/edit').to_not be_routable }
    it { expect(put '/posts/1').to_not be_routable }
    it { expect(delete '/posts/1').to_not be_routable }
  end

  describe :helpers.to_s do
    it { expect(new_post_path).to eq('/posts/new') }
  end

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

    let(:blog) { BlogData.first.to_param }
    let(:params) { FactoryGirl.attributes_for :post_datum }

    context 'for a Registered User' do
      describe 'with valid parameters' do
        before :each do
          @user = FactoryGirl.create :user_datum
          session[:user_id] = @user.id
          post :create, post_data: params, blog: blog
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
          post :create, post_data: params, blog: blog
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
end # describe PostsController
