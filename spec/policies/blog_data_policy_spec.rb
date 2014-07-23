
require 'spec_helper'

describe BlogDataPolicy do
  subject { BlogDataPolicy }
  let(:guest_user) { UserData.first }
  let(:registered_user) { FactoryGirl.build :user_datum }
  let(:instance) { SessionData.new }

  permissions :index? do

    it 'permits the Guest User to invoke the :index action' do
      expect(subject).to permit(guest_user, instance)
    end

    it 'permits a Registered User to invoke the :index action' do
      expect(subject).to permit(registered_user, instance)
    end
  end # permissions :new?
end # describe BlogDataPolicy
