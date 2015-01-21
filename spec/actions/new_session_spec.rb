
require 'spec_helper'
require 'support/broadcast_success_tester'

require 'new_session'

module Actions
  describe NewSession do
    let(:guest_user) { UserRepository.new.guest_user.entity }
    let(:subscriber) { BroadcastSuccessTester.new }
    let(:user_entity) { Newpoc::Entity::User }

    # Regardless of expected success or failure, these are the steps...
    before :each do
      command.subscribe subscriber
      command.execute
    end

    context 'is successful with valid parameters' do
      let(:command) { described_class.new guest_user }

      it 'broadcasts :success' do
        expect(subscriber).to be_successful
        expect(subscriber).not_to be_failure
      end

      describe 'broadcasts :success with a payload which' do
        let(:payload) { subscriber.payload_for(:success).first }

        it 'is the Guest User entity' do
          expect(payload).to be_a user_entity
          expect(payload.slug).to eq 'guest-user'
        end
      end # describe 'broadcasts :success with a payload which'
    end # context 'is successful with valid parameters'

    context 'is unsuccessful with invalid parameters' do
      let(:other_user) { user_entity.new FactoryGirl.attributes_for(:user) }
      let(:command) do
        UserRepository.new.add other_user
        described_class.new other_user
      end

      it 'broadcasts :failure' do
        expect(subscriber).not_to be_successful
        expect(subscriber).to be_failure
      end

      it 'broadcasts failure with the correct error message' do
        payload = subscriber.payload_for(:failure).first
        expect(payload).to eq "Already logged in as #{other_user.name}!"
      end
    end # context 'is unsuccessful with invalid parameters'
  end # describe Actions::NewSessions
end # module Actions
