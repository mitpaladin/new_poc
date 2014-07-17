
require 'spec_helper'

describe UserDataPolicy do
  subject(:policy) { UserDataPolicy.new user, record }
  let(:record) { FactoryGirl.build :user_datum }

  context 'for the Guest User' do
    let(:user) { UserData.first }

    describe 'permits' do
      after :each do
        action = RSpec.current_example.description.to_sym
        expect(policy).to permit action
      end

      it :create do
      end
    end # describe 'does not permit'
  end # context 'for the Guest User'

  context 'for a Registered User' do
    let(:user) { FactoryGirl.build :user_datum }

    describe 'does not permit' do
      after :each do
        action = RSpec.current_example.description.to_sym
        expect(policy).to_not permit action
      end

      it :create do
      end
    end # describe 'permits'
  end # context 'for a Registered User'
end # describe UserDataPolicy
