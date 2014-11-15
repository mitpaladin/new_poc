
require 'spec_helper'

require 'new_post'

module Actions
  describe NewPost do
    let(:klass) { NewPost }
    let(:repo) { UserRepository.new }
    let(:subscriber) { BroadcastSuccessTester.new }
    let(:current_user) do
      user = UserEntity.new FactoryGirl.attributes_for :user, :saved_user
      repo.add user
      user
    end
    let(:guest_user) { repo.guest_user.entity }

    before :each do
      command.subscribe subscriber
      command.execute
    end

    context 'with the Guest User as the current user' do
      let(:command) { klass.new repo.guest_user.entity }

      it 'is unsuccessful' do
        expect(subscriber).not_to be_successful
        expect(subscriber).to be_failure
      end

      describe 'is unsuccessful, broadcasting a StoreResult payload with' do
        let(:payload) { subscriber.payload_for(:failure).first }

        it 'a :success value of false' do
          expect(payload).not_to be_success
        end

        it 'a correct :errors item' do
          message = 'Not logged in as a registered user!'
          expect(payload).to have(1).error
          expect(payload.errors.first)
              .to be_an_error_hash_for :user, message
        end

        it 'an :entity value of nil' do
          expect(payload.entity).to be nil
        end
      end # describe 'is unsuccessful, broadcasting a StoreResult payload...'
    end # context 'with the Guest User as the current user'

    context 'with a Registered User as the current user' do
      let(:command) { klass.new current_user }

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

        description = 'a PostEntity instance for an :entity value, with the' \
            ' author name as the only assigned attribute'
        it description do
          expect(payload.entity).to be_a PostEntity
          expect(payload.entity).to have(1).attribute
          expect(payload.entity.author_name).to eq current_user.name
        end
      end # describe 'is successful, broadcasting a StoreResult payload with'
    end # context 'with a Registered User as the current user'
  end # describe Actions::NewPost
end # module Actions
