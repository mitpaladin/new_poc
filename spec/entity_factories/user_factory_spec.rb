
require 'spec_helper'
require_relative 'shared_examples/an_entity_factory_for'

describe UserFactory do
  let(:klass) { described_class }
  let(:dao) { FactoryGirl.create :user, :saved_user }

  it_behaves_like 'an entity factory for', Entity::User

  describe 'has a .guest_user class method returning an instance that' do
    let(:created_at) { Time.now }
    let(:guest) { described_class.guest_user }

    it 'asserts that it is a Guest User' do
      expect(guest).to be_guest_user
    end
    # other tests elided since .guest_user is now simply delegated
  end # describe 'has a .guest_user class method returning an instance that'
end
