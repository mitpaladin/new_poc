
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

        it 'is a UserEntity' do
          expect(payload).to be_a UserEntity
        end

        it 'has the new user entity attributes in its entity' do
          expect(payload).to be_saved_user_entity_for user_data
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

        describe 'broadcasts :failure with a payload which' do
          let(:payload) { subscriber.payload_for(:failure).first }

          it 'is a String' do
            expect(payload).to be_a String
          end

          it 'is the JSON representation of the correct error message' do
            expected = "Already logged in as #{other_user.name}!".to_json
            expect(payload).to eq expected
          end
        end # describe 'broadcasts :success with a payload which'
      end # context 'there is already a user logged in'

      context 'the user data is invalid' do
        let(:bogus_data) do
          user_data.tap do |data|
            data.password = 'x'
            data.delete :slug
          end
        end
        # let(:bogus_data) { user_data.tap { |data| data.password = 'x' } }
        let(:command) { klass.new guest_user, bogus_data }

        it 'broadcasts :failure' do
          expect(subscriber).not_to be_successful
          expect(subscriber).to be_failure
        end

        describe 'broadcasts :failure with a payload which' do
          let(:payload) { subscriber.payload_for(:failure).first }

          it 'is a JSON-encoded Hash' do
            expect(JSON.parse(payload)).to be_a Hash
          end

          it 'contains the specified user data' do
            data = JSON.parse(payload).symbolize_keys
            expect(data).to eq bogus_data.to_h
          end
        end # describe 'broadcasts :failure with a payload which'
      end # context 'the user data is invalid'
    end # context 'is unsuccessful with parameters that are invalid because'
  end # describe Actions::CreateUser
end # module Actions
