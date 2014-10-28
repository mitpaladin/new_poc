
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
      subject.current_user = UserData.first
      post :create, name: name, password: password
    end

    it 'redirects to the "Sign In" page again' do
      expect(response).to redirect_to new_session_path
    end

    it 'does not change the session data item for the user ID' do
      expect(subject.current_user.attributes).to eq UserData.first.attributes
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

  xdescribe "GET 'new'" do

    context 'for the Guest User' do
      before :each do
        get :new
      end

      # it 'assigns a SessionDataPolicy instance to :policy' do
      #   expect(assigns[:policy]).to be_a SessionDataPolicy
      # end

      it 'renders the :new template' do
        expect(response).to render_template :new
      end

      it 'returns HTTP success' do
        expect(response).to be_ok
      end
    end # context 'for the Guest User'

    context 'for a Registered User' do
      before :each do
        subject.current_user = FactoryGirl.create :user_datum
        get :new
      end

      it 'returns HTTP Redirection' do
        expect(response).to be_redirection
      end

      it 'redirects to the root path' do
        expect(response).to redirect_to root_path
      end

      it 'has the correct flash error message' do
        message = 'You are not authorized to perform this action.'
        expect(flash[:error]).to eq message
      end
    end # context 'for a Registered User'
  end # describe "GET 'new'"

  xdescribe "POST 'create'" do

    context 'for the Guest User' do
      describe 'with valid params' do
        let(:user) { FactoryGirl.create :user_datum }

        before :each do
          post :create, name: user.name, password: user.password
        end

        it 'redirects to the root URL' do
          expect(response).to redirect_to root_url
        end

        it 'sets the current logged-in user to the specified user' do
          expect(subject.current_user.attributes).to eq user.attributes
        end

        it 'sets the logged-in flash message' do
          expect(flash[:success]).to eq 'Logged in!'
        end
      end # describe 'with valid params'

      describe 'with parameters that are invalid because' do

        it_behaves_like 'invalid login credentials', :name

        it_behaves_like 'invalid login credentials', :password
      end # describe 'with parameters that are invalid because'
    end # context 'for the Guest User'
  end # describe "POST 'create'"

  xdescribe "DELETE 'destroy'" do

    before :each do
      @guest_user = UserData.first
      user = FactoryGirl.create :user_datum
      subject.current_user = user
      post :destroy, id: user.slug
    end

    it 'sets the session data item for the user ID to the Guest User' do
      expect(subject.current_user.attributes).to eq @guest_user.attributes
    end

    it 'redirects to the root URL' do
      expect(response).to redirect_to root_url
    end

    it 'sets the "Logged out!" flash message' do
      expect(flash[:success]).to eq 'Logged out!'
    end
  end # describe "DELETE 'destroy'"
end # describe SessionsController
