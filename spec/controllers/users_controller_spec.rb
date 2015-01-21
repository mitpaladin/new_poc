
require 'spec_helper'

require 'current_user_identity'

# Users controller dispatches user-specific actions
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
        user = UserPasswordEntityFactory.create attribs, 'password'
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
        expect(index_users[index]).to eq user
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

      it 'assigns a User entity instance to :user' do
        expect(assigns[:user]).to be_a Newpoc::Entity::User
      end

      it 'renders the :new template' do
        expect(response).to render_template :new
      end
    end # context 'with no user logged in'

    context 'with a user logged in' do
      let(:user_attrs) { FactoryGirl.attributes_for :user, :saved_user }
      let(:user) do
        user = UserPasswordEntityFactory.create user_attrs, 'password'
        UserRepository.new.add user
        user
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
    let(:params) { FancyOpenStruct.new FactoryGirl.attributes_for(:user) }

    describe 'with valid parameters' do
      before :each do
        post :create, user_data: params
      end

      it 'assigns the :user item as a User entity instance' do
        expect(assigns[:user]).to be_a Newpoc::Entity::User
      end

      it 'persists the User entity corresponding to the :user' do
        expect(assigns[:user]).to be_persisted
      end

      it 'redirects to the root path' do
        expect(response).to redirect_to root_path
      end

      it 'displays the "Thank you for signing up!" flash message' do
        expect(request.flash[:success]).to eq 'Thank you for signing up!'
      end
    end # describe 'with valid parameters'

    context 'with invalid parameters' do

      context 'that result in an apparently valid user entity, such as' do
        # This tests a new user that would be valid if a user with the same name
        # weren't already registered. At the entity level, it's fine; it takes a
        # database hit to trip us up.
        context 'a duplicate name' do
          before :each do
            post :create, user_data: params
            params[:profile] = "Updated #{params[:profile]}"
            post :create, user_data: params
            @user = assigns[:user]
          end

          it 'assigns a User entity to :user' do
            expect(@user).to be_a Newpoc::Entity::User
          end

          it 'does not redirect' do
            expect(response).not_to be_redirect
          end

          it 'adds the name-already-taken error message to the :user entity' do
            user_slug = params[:name].parameterize
            message = 'Name is invalid: A record identified by slug' \
              " '#{user_slug}' already exists!"
            expect(@user.errors.full_messages).to include message
          end
        end # context 'a duplicate name'
      end # context 'that result in an apparently valid user entity, such as'

      context 'that result in a visibly invalid user entity, including' do

        after :each do
          post :create, user_data: @params
          expect(response).not_to be_redirection
          user = assigns[:user]
          expect(user).to be_a Newpoc::Entity::User
          expect(user).to be_invalid
          expect(user).to have(@messages.count).errors
          expect(user.errors.full_messages).to end_with @messages
        end

        it 'an empty name' do
          @params = params.merge name: ''
          params[:name] = ''
          @messages = [
            "Name can't be blank",
            'Name is too short (minimum is 6 characters)'
          ]
        end

        it 'an invalid email address' do
          @params = params.merge email: 'jruser at example dot com'
          @messages = [
            'Email does not appear to be a valid e-mail address'
          ]
        end
      end # context 'that result in a visibly invalid user entity, including'

      context 'that result in a visibly valid user entity, including' do

        after :each do
          post :create, user_data: @params
          expect(response).not_to be_redirection
          user = assigns[:user]
          expect(user).to be_a Newpoc::Entity::User
          expect(user).to have(@messages.count).errors
          expect(user.errors.full_messages).to end_with @messages
        end

        it 'mismatched passwords' do
          bad_params = {
            password: 'password',
            password_confirmation: 'Password'
          }
          @params = params.merge bad_params
          prefix = 'Password is invalid: '
          @messages = [
            prefix + 'Password must match the password confirmation'
          ]
        end

        it 'too short passwords' do
          bad_params = {
            password: 'pword',
            password_confirmation: 'pword'
          }
          @params = params.merge bad_params
          prefix = 'Password is invalid: '
          @messages = [
            prefix + 'Password must be longer than 7 characters'
          ]
        end
      end # context '
    end # describe 'with valid entity parameters'
  end # describe "POST 'create'"

  describe "GET 'edit'" do
    let(:not_auth_message) { "Not logged in as #{user.name}!" }
    let(:user) { FactoryGirl.create :user, :saved_user }

    context 'for the Guest User' do

      before :each do
        get :edit, id: user.name.parameterize
      end

      it 'displays the authorisation-failure flash message' do
        expect(request.flash[:alert]).to eq not_auth_message
      end

      it 'redirects to the root path' do
        expect(response).to redirect_to root_path
      end
    end # context 'for the Guest User'

    context 'for the logged-in user' do
      before :each do
        CurrentUserIdentity.new(session).current_user = user
      end

      context 'editing his own record' do

        before :each do
          get :edit, id: user.slug
        end

        it 'is successful' do
          expect(response).to be_ok
        end

        it 'renders the :edit template' do
          expect(response).to render_template :edit
        end

        it 'assigns the :user variable to the logged-in user entity' do
          expect(assigns[:user]).to eq user
        end
      end # context 'editing his own record'

      context 'attempting to edit the record of another user' do
        let(:not_auth_message) { "Not logged in as #{other_user.name}!" }
        let(:other_user) { FactoryGirl.create :user, :saved_user }

        before :each do
          get :edit, id: other_user.slug
        end

        it 'redirects to the root path' do
          expect(response).to redirect_to root_path
        end

        it 'displays the authorisation-failure flash message' do
          expect(request.flash[:alert]).to eq not_auth_message
        end
      end
    end # context 'for the logged-in user'
  end # describe "GET 'edit'"

  # As yet, oblivious to current-user status.
  describe "GET 'show'" do
    before :each do
      get :show, id: target_user.slug
    end

    describe 'succeeds in requesting any existing public profile, so that it' do
      let(:target_user) do
        user_attribs = FactoryGirl.attributes_for(:user, :saved_user)
        entity = UserPasswordEntityFactory.create user_attribs, 'password'
        UserRepository.new.add entity
        entity
      end

      it 'assigns the target user to the :user variable' do
        expect(assigns[:user]).to eq target_user
      end

      it 'has an HTTP status response of OK' do
        expect(response).to be_ok
      end

      it 'renders the :show template' do
        expect(response).to render_template :show
      end
    end # describe 'succeeds in requesting any existing public profile, ...'

    describe 'when attempting to view a profile which does not exist,' do
      let(:target_user) { FancyOpenStruct.new slug: 'invalid-user-slug' }

      it 'is redirected to the user-index page' do
        expect(response).to redirect_to users_path
      end

      it 'is shown the correct flash error message' do
        message = "Cannot find user identified by slug #{target_user.slug}!"
        expect(flash[:alert]).to eq message
      end
    end # describe 'when attempting to view a profile which does not exist,'
  end # describe "GET 'show'"

  describe "PATCH 'update'" do
    let(:user) { FactoryGirl.create :user, :saved_user }
    let(:updated_profile) { 'UPDATED ' + user[:profile] }
    let(:identity) { CurrentUserIdentity.new session }

    context 'for a logged-in user' do
      before :each do
        identity.current_user = user
        params = {
          id:         identity.ident_for(identity.current_user),
          user_data:  {
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
    end # context 'for a logged-in user'

    context 'for the Guest User' do
      let(:params) do
        {
          id: user.slug,
          user_data: {
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
        expect(assigns[:user]).to be nil
        expect(UserDao.find(user.slug).profile).to eq user.profile
      end

      it 'has the correct flash message' do
        expected = 'Not logged in as a registered user!'
        expect(flash[:alert]).to eq expected
      end
    end # context 'for the Guest User'
  end # describe "PATCH 'update'"
end # describe UsersController
