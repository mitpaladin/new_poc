
require 'spec_helper'

require 'show_user'

module Actions
  describe ShowUser do
    let(:command) { klass.new target_user.slug }
    let(:klass) { ShowUser }
    let(:repo) { UserRepository.new }
    let(:subscriber) { BroadcastSuccessTester.new }

    before :each do
      command.subscribe subscriber
      command.execute
    end

    context 'for an existing user profile' do
      let(:target_user) do
        user = UserEntity.new FactoryGirl.attributes_for :user, :saved_user
        repo.add user
        user
      end

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

        it 'the target user as the :entity' do
          expect(payload.entity.slug).to eq target_user.slug
        end
      end # describe 'is successful, broadcasting a StoreResult payload with'
    end # context 'for an existing user profile' do

    context 'for a nonexistent user profile' do
      let(:target_user) { FancyOpenStruct.new slug: 'invalid-user-slug' }

      it 'is not successul' do
        expect(subscriber).not_to be_successful
        expect(subscriber).to be_failure
      end

      describe 'is unsuccessful, broadcasting a StoreResult payload with' do
        let(:payload) { subscriber.payload_for(:failure).first }

        it 'a :success value of false' do
          expect(payload).not_to be_success
        end

        it 'an :errors array containing the correct error information' do
          expect(payload).to have(1).error
          expect(payload.errors.first).to be_an_error_hash_for :user,
              "Cannot find user with slug #{target_user.slug}!"
        end

        it 'an :entity value of nil' do
          expect(payload.entity).to be nil
        end
      end # describe 'is unsuccessful, broadcasting a StoreResult payload with'
    end # context 'for a nonexistent user profile'
  end # describe Actions::ShowUser
end # module Actions
