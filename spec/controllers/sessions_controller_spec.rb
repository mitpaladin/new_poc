
require 'spec_helper'

shared_examples 'invalid login credentials' do |invalid_field_sym|
  user = FactoryGirl.create :user_datum
  if invalid_field_sym == :name
    name = 'An Invalid User Name'
    password = user.password
    description_str = 'the named user does not exist'
  elsif invalid_field_sym == :password
    name = user.name
    password = 'Bogus Password'
    description_str = 'the password is incorrect'
  end

  describe description_str do
    before :each do
      post :create, name: name, password: password
    end

    it 'redirects to the "Sign In" page again' do
      expect(response).to redirect_to new_session_path
    end

    it 'does not set the session data item for the user ID' do
      expect(session[:user_id]).to be_nil
    end

    it 'sets the "Invalid user name or password" flash alert message' do
      expect(flash[:alert]).to eq 'Invalid user name or password'
    end
  end # describe description_str

  user.delete
end # shared_examples 'invalid login credentials'

# SessionsController: responsible for logging users in and out.
describe SessionsController do

  describe :routing.to_s, type: :routing do
    it { expect(get '/sessions/new').to route_to 'sessions#new' }
    it { expect(post '/sessions').to route_to 'sessions#create' }
    it { expect(get '/sessions').to_not be_routable }
    it { expect(get '/sessions/1').to_not be_routable }
    it { expect(get '/sessions/edit').to_not be_routable }
    it { expect(put '/sessions/1').to_not be_routable }
    it { expect(delete '/sessions/1').to route_to 'sessions#destroy', id: '1' }
  end

  describe :helpers.to_s do
    it { expect(new_session_path).to eq '/sessions/new' }
    it { expect(sessions_path).to eq '/sessions' }
    it { expect(session_path(1)).to eq '/sessions/1' }
  end

  describe "POST 'create'" do

    describe 'with valid params' do
      let(:user) { FactoryGirl.create :user_datum }

      before :each do
        post :create, name: user.name, password: user.password
      end

      it 'redirects to the root URL' do
        expect(response).to redirect_to root_url
      end

      it 'saves the user ID number in the session data' do
        expect(session[:user_id]).to eq user.id
      end

      it 'sets the logged-in flash message' do
        expect(flash[:success]).to eq 'Logged in!'
      end
    end # describe 'with valid params'

    describe 'with parameters that are invalid because' do

      it_behaves_like 'invalid login credentials', :name

      it_behaves_like 'invalid login credentials', :password

      describe 'the password is incorrect' do
        let(:user) { FactoryGirl.create :user_datum }

        before :each do
          post :create, name: user.name, password: 'bogus password'
        end

        it 'redirects to the "Sign In" page again' do
          expect(response).to redirect_to new_session_path
        end

        it 'does not set the session data item for the user ID' do
          expect(session[:user_id]).to be_nil
        end

        it 'sets the "Invalid user name or password" flash alert message' do
          expect(flash[:alert]).to eq 'Invalid user name or password'
        end
      end # describe 'the password is incorrect'
    end # describe 'with parameters that are invalid because'
  end # describe "POST 'create'"

  describe "DELETE 'destroy'" do

    before :each do
      @user = FactoryGirl.create :user_datum
      post :create, name: @user.name, password: @user.password
      expect(session[:user_id]).to_not be_nil
      delete :destroy, id: @user.id
    end

    it 'clears the session data item for the user ID' do
      expect(session[:user_id]).to be_nil
    end

    it 'redirects to the root URL' do
      expect(response).to redirect_to root_url
    end

    it 'sets the "Logged out!" flash message' do
      expect(flash[:success]).to eq 'Logged out!'
    end
  end # describe "DELETE 'destroy'"
end # describe SessionsController
