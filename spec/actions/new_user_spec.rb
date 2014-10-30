
require 'spec_helper'

require 'new_user'

module Actions
  describe NewUser do
    let(:klass) { NewUser }
    let(:repo) { UserRepository.new }
    let(:subscriber) { BroadcastSuccessTester.new }
    let(:current_user) do
      user = UserEntity.new FactoryGirl.attributes_for :user, :saved_user
      repo.add user
      user
    end

    before :each do
      command.subscribe subscriber
      command.execute
    end

    context 'with the Guest User as the current user' do
      let(:command) { klass.new repo.guest_user.entity }

      it 'is successful' do
        expect(subscriber).to be_successful
        expect(subscriber).not_to be_failure
      end

      describe 'is successful, broadcasting a StoreResult payload with' do
        let(:payload) { subscriber.payload_for(:success).first }

        it 'a :success value of true' do
          expect(payload).to be_success
        end

        it 'an empty :errors item' do
          expect(payload.errors).to be_empty
        end

        it 'an empty UserEntity instance for an :entity value' do
          expect(payload.entity).to be_a UserEntity
          expect(payload.entity.attributes).to be_empty
        end
      end # describe 'is successful, broadcasting a StoreResult payload with'
    end # context 'with the Guest User as the current user'

    context 'with a Registered User as the current user' do
      let(:command) { klass.new current_user }

      it 'is unsuccessful' do
        expect(subscriber).not_to be_successful
        expect(subscriber).to be_failure
      end

      describe 'is unsuccessful, broadcasting a StoreResult payload with' do
        let(:payload) { subscriber.payload_for(:failure).first }

        it 'a :success value of false' do
          expect(payload).not_to be_success
        end

        it 'an :errors item with the correct information' do
          message = "Already logged in as #{current_user.name}!"
          expect(payload).to have(1).error
          expect(payload.errors.first).to be_an_error_hash_for :user, message
        end
      end # describe 'is unsuccessful, broadcasting a StoreResult payload with'
    end # context 'with a Registered User as the current user'
  end # describe Actions::NewUser
end # module Actions
