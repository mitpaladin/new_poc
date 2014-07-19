
require 'spec_helper'

describe UserDataPolicy do
  subject { UserDataPolicy }
  let(:guest_user) { UserData.first }
  let(:registered_user) { FactoryGirl.build :user_datum }
  let(:instance) { UserData.new }

  permissions :create? do

    it 'permits the Guest User to invoke the :create action' do
      expect(subject).to permit(guest_user, instance)
    end

    it 'prohibits a Registered User from invoking the :create action' do
      expect(subject).not_to permit(registered_user, instance)
    end
  end # permissions :new?
end # describe UserDataPolicy
