
require 'spec_helper'
require_relative 'shared_examples/an_entity_factory_for'

describe UserFactory do
  let(:klass) { described_class }
  let(:dao) { FactoryGirl.create :user, :saved_user }

  it_behaves_like 'an entity factory for', Newpoc::Entity::User

  describe 'has a .guest_user class method returning an instance that' do
    let(:created_at) { Time.now }
    let(:guest) { described_class.guest_user }

    it 'asserts that it is a Guest User' do
      expect(guest).to be_guest_user
    end

    describe 'has the correct details for a Guest User, including' do
      it 'name' do
        expect(guest.name).to eq 'Guest User'
      end

      it 'email' do
        expect(guest.email).to eq 'guest@example.com'
      end

      it 'no slug set' do
        expect(guest.slug).to be nil
      end

      it 'no updated-at timestamp' do
        expect(guest.updated_at).to be nil
      end

      it 'a created-at timestamp of (roughly) now' do
        expect(guest.created_at).to be_within(0.5.seconds).of created_at
      end
    end # describe 'has the correct details for a Guest User, including'
  end # describe 'has a .guest_user class method returning an instance that'
end
