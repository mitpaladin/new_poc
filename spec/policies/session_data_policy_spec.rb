
require 'spec_helper'

describe SessionDataPolicy do
  subject(:policy) { SessionDataPolicy.new user, record }
  let(:record) do
    ret = SessionData.new
    ret.id = user.id
    ret
  end

  context 'for the Guest User' do
    let(:user) { UserData.first }

    describe 'permits' do
      [:create, :new].each do |action|
        it "permits #{action}" do
          expect(policy).to permit action
        end
      end
    end # describe 'permits'

    it 'does not permit :destroy' do
      expect(policy).to_not permit :destroy
    end
  end # context 'for the Guest User'

  context 'for a Registered User' do
    let(:user) { FactoryGirl.build :user_datum }

    describe 'does not permit' do
      [:create, :new].each do |action|
        it "permits #{action}" do
          expect(policy).to_not permit action
        end
      end
    end # describe 'does not permit'

    it 'permits :destroy' do
      expect(policy).to permit :destroy
    end
  end # context 'for a Registered User'
end # describe SessionDataPolicy
