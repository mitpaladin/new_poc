
require 'spec_helper'

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
    it 'returns http success' do
      get :new
      response.should be_success
    end

    it 'assigns a PostData instance to :post' do
      get :new
      expect(assigns[:post]).to be_a PostData
    end

    it 'renders the :new template' do
      get :new
      expect(response).to render_template :new
    end
  end # describe "GET 'new'"

  describe "POST 'create'" do

    let(:blog) { BlogData.first.to_param }
    let(:params) { FactoryGirl.attributes_for :post_datum }

    describe 'with valid parameters' do
      before :each do
        post :create, post_data: params, blog: blog
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
  end # describe "POST 'create'"
end # describe PostsController
