
require 'spec_helper'
require 'support/broadcast_success_tester'

require 'create_session'

description = 'a broadcast :create failure for'
shared_examples description do |description, name, password|
  context description do
    let(:command) do
      user_name = name == :registered_user ? registered_user.name : name
      described_class.new user_name, password
    end

    it 'broadcasts failure' do
      expect(subscriber).not_to be_successful
      expect(subscriber).to be_failure
    end

    describe 'broadcasts :failure with a payload which' do
      let(:payload) { subscriber.payload_for(:failure).first }

      it 'is the correct error message' do
        expect(payload).to eq 'Invalid user name or password'
      end
    end # describe 'broadcasts :failure with a payload which'
  end # context description
end # shared_examples 'a broadcast :create failure for'

module Actions
  describe CreateSession do
    let(:guest_user) { UserRepository.new.guest_user.entity }
    let(:registered_user) do
      user = UserEntity.new FactoryGirl.attributes_for(:user, :saved_user)
      UserRepository.new.add user
      user
    end
    let(:subscriber) { BroadcastSuccessTester.new }

    # regardless of parameters, these steps wire up the Wisper connection
    before :each do
      command.subscribe subscriber
      command.execute
    end

    context 'is successful with valid parameters' do
      let(:command) do
        described_class.new registered_user.name, registered_user.password
      end

      it 'broadcasts :success' do
        expect(subscriber).to be_successful
        expect(subscriber).not_to be_failure
      end

      describe 'broadcasts :success with a payload which' do
        let(:payload) { subscriber.payload_for(:success).first }

        it 'is a UserEntity' do
          expect(payload).to be_a UserEntity
        end

        it 'has the correct user attributes' do
          expect(payload).to be_saved_user_entity_for registered_user
        end
      end # describe 'broadcasts :success with a payload which'
    end # context 'is successful with valid parameters'

    context 'is unsuccessful with invalid parameters' do

      it_behaves_like 'a broadcast :create failure for', 'an invalid user name',
                      '  Invalid  User  ', 'password'

      it_behaves_like 'a broadcast :create failure for',
                      'a valid user name but invalid password',
                      :registered_user, 'bad password'
    end # context 'is unsuccessful with invalid parameters'
  end # describe Actions::CreateSessions
end # module Actions
