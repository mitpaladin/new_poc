
require 'spec_helper'

describe UserDataPolicy do
  subject { UserDataPolicy }
  let(:guest_user) { UserData.first }
  let(:registered_user) { FactoryGirl.build :user_datum }
  let(:instance) { FactoryGirl.build :user_datum }

  permissions :index? do
    it 'permits the Guest User to invoke the :index action' do
      expect(subject).to permit(guest_user, instance)
    end

    it 'permits a registered user to invoke the :index action' do
      expect(subject).to permit(registered_user, instance)
    end

  end

  permissions :create? do

    it 'permits the Guest User to invoke the :create action' do
      expect(subject).to permit(guest_user, instance)
    end

    it 'prohibits a Registered User from invoking the :create action' do
      expect(subject).not_to permit(registered_user, instance)
    end
  end # permissions :create?

  permissions :edit? do

    describe 'does not permit invoking the :edit action by' do
      it 'the Guest User' do
        expect(subject).not_to permit(guest_user, instance)
      end

      it 'a user other than the specified user' do
        expect(subject).not_to permit(registered_user, instance)
      end
    end # describe 'does not permit'

    it 'permits the subject user to invoke :edit on his own record' do
      expect(subject).to permit(registered_user, registered_user)
    end
  end # permissions :edit?

  permissions :update? do

    describe 'does not permit invoking the :update action by' do
      it 'the Guest User' do
        expect(subject).not_to permit(guest_user, instance)
      end

      it 'a user other than the specified user' do
        expect(subject).not_to permit(registered_user, instance)
      end
    end # describe 'does not permit'

    it 'permits the subject user to invoke :update on his own record' do
      expect(subject).to permit(registered_user, registered_user)
    end
  end # permissions :update?
end # describe UserDataPolicy
