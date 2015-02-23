
require 'spec_helper'
require 'support/broadcast_success_tester'

require 'update_user'

module Actions
  describe UpdateUser do
    let(:command) { described_class.new user_data, current_user }
    let(:subscriber) { BroadcastSuccessTester.new }
    let(:user_repo) { UserRepository.new }

    # regardless of parameters, these steps wire up the Wisper connection
    before :each do
      command.subscribe subscriber
      command.execute
    end

    context 'for a Registered User' do
      let(:current_user) do
        user_attribs = FactoryGirl.attributes_for :user, :saved_user
        entity = UserPasswordEntityFactory.create user_attribs, 'password'
        user_repo.add entity
        entity
      end

      describe "can update that user's own" do
        let(:payload) { subscriber.payload_for(:success).first }

        describe 'email address' do
          let(:user_data) { { email: 'new_user@example.com' } }

          it 'successfully' do
            expect(payload).to be_a Newpoc::Entity::User
            expect(payload[:email]).to eq user_data[:email]
          end
        end # describe 'email address'

        describe 'profile description' do
          let(:user_data) { { profile: '*Updated* profile.' } }

          it 'successfully' do
            expect(payload).to be_a Newpoc::Entity::User
            expect(payload[:profile]).to eq user_data[:profile]
            entity = UserRepository.new.find_by_slug(payload.slug).entity
            expect(entity[:profile]).to eq user_data[:profile]
          end
        end # describe 'profile description'

        describe 'password/confirmation pair' do
          let(:user_data) do
            {
              password: 'new password',
              password_confirmation: 'new password'
            }
          end

          it 'successfully, without returning password data' do
            expect(payload).to be_a Newpoc::Entity::User
            expect(payload).to be_valid
            [:password, :password_confirmation, :password_hash].each do |attr|
              expect(payload.attributes).not_to have_key attr
            end
          end
        end # describe 'password/confirmation pair'
      end # describe "can update that user's own"

      describe 'is notified of errors when' do
        let(:payload) do
          data = subscriber.payload_for(:failure).first
          Yajl.load data, symbolize_keys: true
        end
        let(:user_data) do
          {
            password: 'password',
            password_confirmation: 'password confirmation ;-)'
          }
        end

        it 'entered password and confirmation do not match' do
          expect(payload).to be_a Hash
          expected = 'Password must match the password confirmation'
          expect(payload[:messages].first).to eq expected
          matching_attributes = [:name, :email, :slug, :profile]
          matching_attributes.each do |attr|
            expect(payload[:entity][attr]).to eq current_user.attributes[attr]
          end
        end
      end # describe 'is notified of errors when'

      describe 'cannot update other attributes, such as' do
        let(:payload) { subscriber.payload_for(:success).first }
        let(:user_data) { { name: 'Somebody Else' } }

        it 'name' do
          expect(payload).to be_a Newpoc::Entity::User
          expect(payload[:name]).not_to eq user_data[:name]
          expect(payload[:name]).to eq current_user[:name]
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

        describe 'is not successful, broadcasting a payload which' do
          let(:payload) do
            data = JSON.parse(subscriber.payload_for(:failure).first)
            FancyOpenStruct.new data
          end

          it 'is the expected error message' do
            expect(payload.to_h).to be_a Hash
            expect(payload).to have(1).message
            expected = 'Not logged in as a registered user!'
            expect(payload.messages.first).to eq expected
          end
        end # describe 'is not successful, broadcasting a payload which'
      end # describe 'cannot update any attributes, such as :profile'
    end # context 'for the Guest User'
  end # describe Actions::UpdateUser
end # module Actions
