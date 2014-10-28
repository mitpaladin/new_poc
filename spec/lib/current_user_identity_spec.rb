
require 'spec_helper'

require 'current_user_identity'

shared_examples 'no user is logged in' do
  it 'returns the guest user from the :current_user method' do
    expect(obj.current_user).to eq guest_user
  end
end # shared_examples do 'no user is logged in'

describe CurrentUserIdentity do
  let(:klass) { CurrentUserIdentity }
  let(:store) { Hash.new }
  let(:invalid_user_id) { 'bogus-bogus-bogus' }
  let(:guest_user) { UserDao.first }
  let(:guest_user_id) { guest_user.slug }
  let(:obj) { klass.new store }

  describe :guest_user?.to_s do
    context 'without a current user having previously been defined' do
      it 'returns true' do
        expect(obj).to be_guest_user
      end
    end # context 'without a current user having previously been defined'

    context 'after a current user has been defined' do
      let(:the_user) { FactoryGirl.create :user_datum }

      before :each do
        store[:user_id] = obj.ident_for the_user
      end

      it 'returns false' do
        expect(obj).not_to be_guest_user
      end
    end # context 'after a current user has been defined'

    context 'when the current user is invalid' do
      before :each do
        obj.current_user = nil
      end

      it 'returns true' do
        expect(obj).to be_guest_user
      end
    end # context 'when the current user is invalid'
  end # describe :guest_user?

  describe :ident_for.to_s do
    it 'returns the slug from the passed-in object' do
      slugged = Struct.new(:slug).new 'some-slug'
      expect(obj.ident_for slugged).to eq slugged.slug
    end
  end # describe :ident_for

  describe :current_user=.to_s do
    context 'when setting an existing user' do
      let(:the_user) { FactoryGirl.create :user, :saved_user }

      before :each do
        obj.current_user = the_user
      end

      it 'sets the return value of the :current_user method' do
        expect(obj.current_user).to eq the_user
      end
    end # context 'when setting an existing user'

    context 'when setting an invalid user' do
      before :each do
        obj.current_user = nil
      end

      it_behaves_like 'no user is logged in'
    end # context 'when setting an invalid user' do
  end # describe :current_user=

  describe :current_user.to_s do
    context 'without a current user having previously been defined' do
      it 'returns the guest user' do
        expect(obj.current_user).to eq guest_user
      end
    end # context 'without a current user having previously been defined'

    context 'after an existing user has been deined as logged-in' do
      let(:the_user) { FactoryGirl.create :user, :saved_user }

      before :each do
        obj.current_user = the_user
      end

      it 'returns the logged-in user' do
        expect(obj.current_user).to eq the_user
      end
    end # context 'after an existing user has been deined as logged-in'

    context 'when an invalid user identifier has been set' do
      before :each do
        obj.send :identifier=, invalid_user_id
      end

      it 'returns the guest user' do
        expect(obj.current_user).to eq guest_user
      end
    end # context 'when an invalid user identifier has been set' do
  end # describe :current_user
end # describe CurrentUserIdentity
