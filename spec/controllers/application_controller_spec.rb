
require 'spec_helper'

describe ApplicationController do

  describe :current_user.to_s do

    after :each do
      @actual = subject.send :current_user
      expect(@actual).to eq @expected
    end

    context 'with no registered user logged in' do

      it 'returns the Guest User' do
        @expected = UserData.find_by_name 'Guest User'
      end
    end # context 'with no registered user logged in'

    context 'with a registered user logged in (according to session data)' do

      it 'returns the logged-in user' do
        @expected = FactoryGirl.create :user_datum
        subject.current_user = @expected
      end
    end
  end # describe :current_user.to_s
end # describe ApplicationController
