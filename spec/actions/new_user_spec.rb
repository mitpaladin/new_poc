
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
    let(:command) { klass.new current_user }

    before :each do
      command.subscribe subscriber
      command.execute
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

      it 'an empty UserEntity instance for an :entity value' do
        expect(payload.entity).to be_a UserEntity
        expect(payload.entity.attributes).to be_empty
      end
    end # describe 'is successful, broadcasting a StoreResult payload with'
  end # describe Actions::NewUser
end # module Actions
