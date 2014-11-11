
require 'spec_helper'

# Users controller dispatches user- (rather, UserData-)specific actions
describe UsersController do
  describe :routing.to_s, type: :routing do
    it { expect(get '/users/new').to route_to 'users#new' }
    it { expect(post '/users').to route_to 'users#create' }
    it { expect(get '/users').to route_to 'users#index' }
    it do
      expect(get '/users/john-doe')
          .to route_to controller: 'users', action: 'show', id: 'john-doe'
    end
    it do
      expect(get '/users/john-doe/edit')
          .to route_to 'users#edit', id: 'john-doe'
    end
    it do
      expect(put '/users/john-doe')
          .to route_to 'users#update', id: 'john-doe'
    end
    it { expect(delete '/users/1').to_not be_routable }
  end

  describe :helpers.to_s do
    it { expect(new_user_path).to eq('/users/new') }
  end

  describe "GET 'index'" do
    before :each do
      get :index
    end

    it 'returns http success' do
      expect(response).to be_success
    end
  end # describe "GET 'index'"

  describe "GET 'new'" do
    before :each do
      get :new
    end

    it 'returns http success' do
      expect(response).to be_success
    end

    it 'assigns a UserData instance to :user' do
      expect(assigns[:user]).to be_a UserData
    end

    it 'renders the :new template' do
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
        @messages = ['Email does not appear to be a valid e-mail address']
      end

      it 'mismatched passwords' do
        params[:password] = 'password'
        params[:password_confirmation] = 'Password'
        @messages = ["Password confirmation doesn't match Password"]
      end
    end # describe 'with invalid parameters, such as'
  end # describe "POST 'create'"

  describe "GET 'show'" do

    context 'for the logged-in user' do
      let(:user) { FactoryGirl.create :user_datum }
      before :each do
        session[:user_id] = user.id
      end

      it 'assigns the user object with the slugged name to :user' do
        get :show, id: user.name.parameterize
        expect(assigns[:user]).to eq user
      end
    end # context 'for the logged-in user'

    context 'for the Guest User' do
    end # context 'for the Guest User'
  end # describe "GET 'show'"

  describe "GET 'edit'" do
    let(:user) { FactoryGirl.create :user_datum }
    let(:not_auth_message) { 'You are not authorized to perform this action.' }

    context 'for the Guest User' do

      before :each do
        get :edit, id: user.name.parameterize
      end

      it 'displays the authorisation-failure flash message' do
        expect(request.flash[:error]).to eq not_auth_message
      end

      it 'redirects to the root path' do
        expect(response).to redirect_to root_path
      end
    end # context 'for the Guest User'

    context 'for the logged-in user' do
      let(:user) { FactoryGirl.create :user_datum }
      before :each do
        session[:user_id] = user.name.parameterize
        get :edit, id: user.name.parameterize
      end

      describe 'editing his own record' do

        it 'is successful' do
          expect(response).to be_ok
        end

      end
    end # context 'for the logged-in user'
  end # describe "GET 'edit'"

  describe "PATCH 'update'" do
    # Why #create rather than just #attributes_for ? So the slug gets built.
    let(:user) { FactoryGirl.create :user_datum }
    let(:updated_profile) { 'UPDATED ' + user[:profile] }

    context 'for a logged-in user' do

      context 'whose record is being updated' do
        before :each do
          session[:user_id] = user.name.parameterize
          params = {
            id:         session[:user_id],
            user_data:  {
              name:     user.name,
              email:    user.email,
              profile:  updated_profile
            }
          }
          patch :update, params
        end

        it 'assigns the updated user record' do
          assigned = assigns[:user]
          expect(assigned[:profile]).to eq updated_profile
        end

        it 'redirects to the user profile page' do
          expect(response).to redirect_to user_path(user.slug)
        end

        it 'has the correct flash message' do
          expected = 'You successfully updated your profile'
          expect(flash[:success]).to eq expected
        end
      end # context 'whose record is being updated'

      context 'who is not the user whose record is being updated' do
        let(:logged_in_user) { FactoryGirl.create :user_datum }
        let(:params) do
          {
            id: user.id,
            user_data: {
              name:     user.name,
              email:    user.email,
              profile:  updated_profile
            }
          }
        end
        before :each do
          session[:user_id] = logged_in_user.name.parameterize
          patch :update, params
        end

        it 'redirects to the landing page' do
          expect(response).to redirect_to root_path
        end

        it 'does not modify the user record' do
          expect(assigns[:user][:profile]).not_to eq updated_profile
          expect(UserData.find(assigns[:user][:id])[:profile])
              .not_to eq updated_profile
        end

        it 'has the correct flash message' do
          expected = 'You are not authorized to perform this action.'
          expect(flash[:error]).to eq expected
        end
      end # context 'who is not the user whose record is being updated'
    end # context 'for a logged-in user'

    context 'for the Guest User' do
      let(:params) do
        {
          id: user.id,
          user_data: {
            name:     user.name,
            email:    user.email,
            profile:  updated_profile
          }
        }
      end
      before :each do
        patch :update, params
      end

      it 'redirects to the landing page' do
        expect(response).to redirect_to root_path
      end

      it 'does not modify the user record' do
        expect(assigns[:user][:profile]).not_to eq updated_profile
        expect(UserData.find(assigns[:user][:id])[:profile])
            .not_to eq updated_profile
      end

      it 'has the correct flash message' do
        expected = 'You are not authorized to perform this action.'
        expect(flash[:error]).to eq expected
      end
    end # context 'for the Guest User'
  end # describe "PATCH 'update'"
end # describe UsersController
