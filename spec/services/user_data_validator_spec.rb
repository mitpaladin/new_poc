
require 'spec_helper'

require 'user_data_validator'

# Only exercising golden path *because*:
# - this is a simple shell around two other classes, and
# - both of those classes are exhaustively specified, so
# - all *this* needs to prove is that the basic API is there.
describe UserDataValidator do
  let(:klass) { UserDataValidator }
  let(:validator) { klass.new user_data }

  context 'valid inputs' do

    describe 'are recognised as valid, including that' do
      let(:user_data) do
        {
          name: 'Joe Palooka',
          email: 'joe@example.com',
          password: 'password',
          password_confirmation: 'password'
        }
      end

      it 'returns true from the #valid? method' do
        expect(validator).to be_valid
      end

      it 'returns an empty collection from the #errors method' do
        expect(validator).to have(0).errors
      end
    end # describe 'are recognised as valid, including that'
  end # context 'valid inputs'
end # describe UserDataValidator
