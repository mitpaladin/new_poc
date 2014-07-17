
require 'spec_helper'

describe BlogDataPolicy do
  subject(:policy) { BlogDataPolicy.new user, record }
  let(:record) { FactoryGirl.build :post_datum }

  context 'for the Guest User' do
    let(:user) { UserData.find_by_name 'Guest User' }

    it 'permits the index action' do
      expect(policy).to permit :index
    end
  end # context 'for the Guest User'

  context 'for a Registered User' do
    let(:user) { FactoryGirl.build :user_datum }

    it 'permits the index action' do
      expect(policy).to permit :index
    end
  end # context 'for a Registered User'
end # describe PostDataPolicy
