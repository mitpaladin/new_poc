
require 'spec_helper'
require 'support/broadcast_success_tester'

require 'update_user'

module Actions
  describe UpdateUser do
    let(:klass) { UpdateUser }
    let(:command) { klass.new user_data, current_user }
    let(:subscriber) { BroadcastSuccessTester.new }
    let(:user_repo) { UserRepository.new }

    # regardless of parameters, these steps wire up the Wisper connection
    before :each do
      command.subscribe subscriber
      command.execute
    end

    context 'for a Registered User' do
      let(:current_user) do
        entity = UserEntity.new FactoryGirl.attributes_for :user, :saved_user
        user_repo.add entity
        entity
      end

      describe "can update that user's own" do
        let(:payload) { subscriber.payload_for(:success).first }

        describe 'email address' do
          let(:user_data) { { email: 'new_user@example.com' } }

          it 'successfully' do
            expect(payload).to be_success
            new_value = payload.entity.attributes[user_data.keys.first]
            expect(new_value).to eq user_data.values.first
          end
        end # describe 'email address'

        describe 'profile description' do
          let(:user_data) { { profile: '*Updated* profile.' } }

          it 'successfully' do
            expect(payload).to be_success
            new_value = payload.entity.attributes[user_data.keys.first]
            expected = user_data.values.first
            expect(new_value).to eq expected
            entity = UserRepository.new.find_by_slug(payload.entity.slug).entity
            expect(entity.attributes[user_data.keys.first]).to eq expected
          end
        end # describe 'profile description'
      end # describe "can update that user's own"

      describe 'cannot update other attributes, such as' do
        let(:payload) { subscriber.payload_for(:success).first }
        let(:user_data) { { name: 'Somebody Else' } }

        it 'name' do
          expect(payload).to be_success
          key = user_data.keys.first
          new_value = payload.entity.attributes[key]
          expect(new_value).to eq current_user.attributes[key]
          expect(new_value).not_to eq user_data[key]
        end
      end # describe 'cannot update other attributes, such as'
    end # context 'for a Registered User'

    context 'for the Guest User' do
      let(:user_data) { { profile: 'updated profile.' } }
      let(:current_user) { user_repo.guest_user.entity }

      describe 'cannot update any attributes, such as :profile,' do
        it 'is not successful' do
          expect(subscriber).not_to be_successful
          expect(subscriber).to be_failure
        end

        describe 'is not successful, broadcasting a StoreResult payload with' do
          let(:payload) { subscriber.payload_for(:failure).first }

          it 'a :success value of false' do
            expect(payload).not_to be_success
          end

          it 'an :errors item with the correct information' do
            message = "Not logged in as a registered user!"
            expect(payload).to have(1).error
            expect(payload.errors.first).to be_an_error_hash_for :user, message
          end

          it 'an :entity value of nil' do
            expect(payload.entity).to be nil
          end
        end # describe 'is not successful, broadcasting a StoreResult payload...'
      end # describe 'cannot update any attributes, such as :profile'
    end # context 'for the Guest User'
  end # describe Actions::UpdateUser
end # module Actions
