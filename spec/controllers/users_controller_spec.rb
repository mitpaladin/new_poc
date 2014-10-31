
require 'spec_helper'

require 'current_user_identity'

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
    let(:repo) { UserRepository.new }
    let(:user_count) { 5 }
    let(:users) { [] }

    before :each do
      user_count.times do
        attribs = FactoryGirl.attributes_for :user, :saved_user
        user = UserEntity.new attribs
        repo.add user
        users << user
      end
      get :index
    end

    it 'returns http success' do
      expect(response).to be_success
    end

    it 'renders the :index template' do
      expect(response).to render_template :index
    end

    it 'assigns the non-Guest users to the :users item' do
      index_users = assigns[:users]
      users.each_with_index do |user, index|
        expect(index_users[index]).to be_saved_user_entity_for user
      end
    end
  end # describe "GET 'index'"

  describe "GET 'new'" do
    before :each do
      get :new
    end

    context 'with no user logged in' do
      it 'returns http success' do
        expect(response).to be_success
      end

      it 'assigns a UserEntity instance to :user' do
        expect(assigns[:user]).to be_a UserEntity
      end

      it 'renders the :new template' do
        expect(response).to render_template :new
      end
    end # context 'with no user logged in'

    context 'with a user logged in' do
      let(:user) do
        ret = UserEntity.new FactoryGirl.attributes_for :user, :saved_user
        UserRepository.new.add ret
        ret
      end

      before :each do
        subject.current_user = user
        get :new
      end

      it 'redirects to the root path' do
        expect(response).to redirect_to root_path
      end

      it 'has the correct flash message' do
        expect(flash[:alert]).to eq "Already logged in as #{user.name}!"
      end
    end # context 'with a user logged in'
  end # describe "GET 'new'"

  describe "POST 'create'" do
    let(:params) { FactoryGirl.attributes_for :user_datum }

    describe 'with valid parameters' do
      before :each do
        post :create, user_data: params
      end

      it 'assigns the :user item as a UserEntity instance' do
        expect(assigns[:user]).to be_a UserEntity
      end

      it 'persists the UserData instance corresponding to the :user' do
        expect(assigns[:user]).to be_persisted
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
        errors = assigns[:errors]
        expect(user).not_to be_persisted
        # expect(user).to_not be_valid
        expect(errors.count).to eq @messages.count
        @messages.each do |k, v|
          expected = { field: k.to_s, message: v }
          expect(errors).to include expected
        end
      end

      it 'an empty name' do
        params[:name] = ''
        @messages = { name: 'may not be missing or blank' }
      end

      it 'a duplicate name' do
        post :create, user_data: params
        expect(assigns[:user]).to be_persisted
        @messages = { name: 'is not available' }
      end

      it 'an invalid email address' do
        params[:email] = 'jruser at example dot com'
        @messages = { email: 'does not appear to be a valid e-mail address' }
      end

      it 'mismatched passwords' do
        params[:password] = 'password'
        params[:password_confirmation] = 'Password'
        @messages = { password: 'and password confirmation do not match' }
      end
    end # describe 'with invalid parameters, such as'
  end # describe "POST 'create'"

  xdescribe "GET 'show'" do

    context 'for the logged-in user' do
      let(:user) { FactoryGirl.create :user_datum }
      before :each do
        CurrentUserIdentity.new(session).current_user = user
      end

      it 'assigns the user object with the slugged name to :user' do
        get :show, id: user.name.parameterize
        expect(assigns[:user]).to eq user
      end
    end # context 'for the logged-in user'

    context 'for the Guest User' do
    end # context 'for the Guest User'
  end # describe "GET 'show'"

  xdescribe "GET 'edit'" do
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
        CurrentUserIdentity.new(session).current_user = user
        get :edit, id: user.name.parameterize
      end

      describe 'editing his own record' do

        it 'is successful' do
          expect(response).to be_ok
        end

      end
    end # context 'for the logged-in user'
  end # describe "GET 'edit'"

  xdescribe "PATCH 'update'" do
    # Why #create rather than just #attributes_for ? So the slug gets built.
    let(:user) { FactoryGirl.create :user_datum }
    let(:updated_profile) { 'UPDATED ' + user[:profile] }
    let(:identity) { CurrentUserIdentity.new session }

    context 'for a logged-in user' do
      before :each do
        identity.current_user = user
      end

      context 'whose record is being updated' do
        before :each do
          params = {
            id:         identity.ident_for(identity.current_user),
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
          identity.current_user = logged_in_user
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
