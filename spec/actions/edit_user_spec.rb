
require 'spec_helper'

require 'edit_user'

module Actions
  describe EditUser do
    let(:klass) { EditUser }
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
      let(:command) { klass.new current_user.slug, repo.guest_user.entity }

      it 'is not successful' do
        expect(subscriber).not_to be_successful
        expect(subscriber).to be_failure
      end

      describe 'is not  successful, broadcasting a StoreResult payload with' do
        let(:payload) { subscriber.payload_for(:failure).first }

        it 'a :success value of false' do
          expect(payload).not_to be_success
        end

        it 'an :errors item with the correct information' do
          message = "Not logged in as "
          message = "Not logged in as #{current_user.slug}!"
          expect(payload).to have(1).error
          expect(payload.errors.first).to be_an_error_hash_for :user, message
        end

        it 'an :entity value of nil' do
          expect(payload.entity).to be nil
        end
      end # describe 'is not successful, broadcasting a StoreResult payload...'
    end # context 'with the Guest User as the current user'

    context 'with the profile owner as the current user' do
      let(:command) { klass.new current_user.slug, current_user }

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

        it 'the current user/profile owner as the :entity' do
          expect(payload.entity.name).to eq current_user.name
        end
      end # describe 'is successful, broadcasting a StoreResult payload with'
    end # context 'with the profile owner as the current user'
  end # describe Actions::EditUser
end # module Actions
