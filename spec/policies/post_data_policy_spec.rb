
require 'spec_helper'

describe PostDataPolicy do
  subject { PostDataPolicy }
  let(:guest_user) { UserData.first }
  let(:registered_user) { FactoryGirl.build :user_datum }
  let(:instance) { SessionData.new }

  permissions :create? do

    it 'prohibits the Guest User from invokuing the :create action' do
      expect(subject).not_to permit(guest_user, instance)
    end

    it 'permits a Registered User to invoke the :create action' do
      expect(subject).to permit(registered_user, instance)
    end
  end # permissions :create?
end # describe PostDataPolicy
