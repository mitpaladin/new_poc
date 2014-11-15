
require 'spec_helper'
require 'support/broadcast_success_tester'

require 'create_user'

module Actions
  describe CreateUser do
    let(:klass) { CreateUser }
    let(:guest_user) { UserRepository.new.guest_user.entity }
    let(:subscriber) { BroadcastSuccessTester.new }
    let(:user_data) do
      FancyOpenStruct.new FactoryGirl.attributes_for(:user, :saved_user)
    end

    # regardless of parameters, these steps wire up the Wisper connection
    before :each do
      command.subscribe subscriber
      command.execute
    end

    context 'is successful with valid parameters' do
      let(:command) { klass.new guest_user, user_data }

      it 'broadcasts :success' do
        expect(subscriber).to be_successful
        expect(subscriber).not_to be_failure
      end

      describe 'broadcasts :success with a payload of a StoreResult, which' do
        let(:payload) { subscriber.payload_for(:success).first }

        it 'is successful' do
          expect(payload).to be_success
        end

        it 'has no errors' do
          expect(payload.errors.to_a).to have(0).errors
        end

        it 'has the new user entity attributes in its entity' do
          expect(payload.entity).to be_saved_user_entity_for user_data
        end
      end # describe 'broadcasts :success with a payload of a StoreResult, ...'
    end # context 'is successful with valid parameters'

    context 'is unsuccessful with parameters that are invalid because' do

      context 'there is already a user logged in' do
        let(:other_user) do
          user = UserEntity.new FactoryGirl.attributes_for(:user, :saved_user)
          UserRepository.new.add user
          user
        end
        let(:command) { klass.new other_user, user_data }

        it 'broadcasts :failure' do
          expect(subscriber).not_to be_successful
          expect(subscriber).to be_failure
        end

        describe 'broadcasts :failure with a payload of a StoreResult, which' do
          let(:payload) { subscriber.payload_for(:failure).first }

          it 'is not successful' do
            expect(payload).not_to be_success
          end

          it 'has one error' do
            expect(payload.errors.to_a).to have(1).errors
            message = ['Already logged in as ', '!'].join other_user.name
            expect(payload.errors.first).to be_an_error_hash_for :user, message
          end

          it 'has an unpersisted UserEntity for an :entity value' do
            expect(payload.entity).to be_a UserEntity
            expect(payload.entity).not_to be_persisted
          end
        end # describe 'broadcasts :success with a payload of a StoreResult, ...'
      end # context 'there is already a user logged in'

      context 'the user data is invalid' do
        let(:bogus_data) { user_data.tap { |data| data.password = 'x' } }
        let(:command) { klass.new guest_user, bogus_data }

        it 'broadcasts :failure' do
          expect(subscriber).not_to be_successful
          expect(subscriber).to be_failure
        end
      end # context 'the user data is invalid'
    end # context 'is unsuccessful with parameters that are invalid because'
  end # describe Actions::CreateUser
end # module Actions
