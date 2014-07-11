
require 'spec_helper'

# Users controller dispatches user- (rather, UserData-)specific actions
describe UsersController do
  describe :routing.to_s, type: :routing do
    it { expect(get '/users/new').to route_to 'users#new' }
    it { expect(post '/users').to route_to 'users#create' }
    it { expect(get '/users').to_not be_routable }
    it { expect(get '/users/1').to_not be_routable }
    it { expect(get '/users/edit').to_not be_routable }
    it { expect(put '/users/1').to_not be_routable }
    it { expect(delete '/users/1').to_not be_routable }
  end

  describe :helpers.to_s do
    it { expect(new_user_path).to eq('/users/new') }
  end

  describe "GET 'new'" do
    it 'returns http success' do
      get :new
      response.should be_success
    end

    it 'assigns a UserData instance to :user' do
      get :new
      expect(assigns[:user]).to be_a UserData
    end

    it 'renders the :new template' do
      get :new
      expect(response).to render_template :new
    end
  end # describe "GET 'new'"

  describe "POST 'create'" do
    let(:params) { FactoryGirl.attributes_for :user_datum }

    describe 'with valid parameters' do
      before :each do
        post :create, user_data: params
      end

      it 'assigns the :user item as a UserData instance' do
        expect(assigns[:user]).to be_a UserData
      end

      it 'persists the UserData instance corresponding to the :user' do
        expect(assigns[:user]).to_not be_a_new_record
      end

      it 'redirects to the root path' do
        expect(response).to redirect_to root_path
      end

      it 'displays the "Thank you for signing up!" flash message' do
        expect(request.flash[:success]).to eq 'Thank you for signing up!'
      end
    end # describe 'with valid parameters'

    describe 'with invalid parameters, such as' do

      after :each do
        post :create, user_data: params
        user = assigns[:user]
        expect(user).to be_a_new_record
        expect(user).to_not be_valid
        messages = user.errors.full_messages
        @messages.each { |expected| expect(messages).to include expected }
      end

      it 'an empty name' do
        params[:name] = ''
        @messages = ['Name is invalid', "Name can't be blank"]
      end

      it 'a duplicate name' do
        post :create, user_data: params
        expect(assigns[:user]).to be_valid
        @messages = ['Name has already been taken']
      end

      it 'an invalid email address' do
        params[:email] = 'jruser at example dot com'
        @messages = ['Email does not appear to be valid']
      end

      it 'mismatched passwords' do
        params[:password] = 'password'
        params[:password_confirmation] = 'Password'
        @messages = ["Password confirmation doesn't match Password"]
      end
    end # describe 'with invalid parameters, such as'
  end # describe "POST 'create'"
end # describe UsersController
