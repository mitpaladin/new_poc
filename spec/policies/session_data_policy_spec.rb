
require 'spec_helper'

describe SessionDataPolicy do
  subject { SessionDataPolicy }
  let(:guest_user) { UserData.first }
  let(:registered_user) { FactoryGirl.build :user_datum }
  let(:instance) { SessionData.new }

  permissions :new? do

    it 'permits the Guest User to invoke the :new action' do
      expect(subject).to permit(guest_user, instance)
    end

    it 'prohibits a Registered User from invoking the :new action' do
      expect(subject).not_to permit(registered_user, instance)
    end
  end # permissions :new?

  permissions :create? do

    it 'permits the Guest User to invoke the :create action' do
      expect(subject).to permit(guest_user, instance)
    end

    it 'prohibits a Registered User from invoking the :create action' do
      expect(subject).not_to permit(registered_user, instance)
    end
  end # permissions :create?

  permissions :destroy? do

    it 'prohibits the Guest User from invoking the :destroy action' do
      expect(subject).not_to permit(guest_user, instance)
    end

    it 'permits a Registered User to invoke the :destroy action' do
      expect(subject).to permit(registered_user, instance)
    end
  end # permissions :destroy?
end # describe SessionDataPolicy
