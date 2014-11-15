
require 'spec_helper'
require 'support/broadcast_success_tester'

require 'create_session'

description = 'a broadcast :create failure for'
shared_examples description do |description, name, password|
  context description do
    let(:command) do
      user_name = name == :registered_user ? registered_user.name : name
      klass.new user_name, password
    end

    it 'broadcasts failure' do
      expect(subscriber).not_to be_successful
      expect(subscriber).to be_failure
    end

    describe 'broadcasts :failure with a payload of a StoreResult, which' do
      let(:payload) { subscriber.payload_for(:failure).first }

      it 'is a failure' do
        expect(payload).not_to be_success
      end

      it 'has one error' do
        expect(payload).to have(1).errors
        expect(payload.errors.first)
            .to be_an_error_hash_for :base, 'Invalid user name or password'
      end
    end # describe 'broadcasts :failure with a payload of a StoreResult,...'
  end # context description
end # shared_examples 'a broadcast :create failure for'

module Actions
  describe CreateSession do
    let(:klass) { CreateSession }
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
      let(:command) { klass.new registered_user.name, registered_user.password }

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
          expect(payload).to have(0).errors
        end

        it 'has the Guest User entity attributes in its entity' do
          [:name, :email, :profile, :slug].each do |field|
            expect(payload.entity.send field).to eq registered_user.send(field)
          end
        end
      end # describe 'broadcasts :success with a payload of a StoreResult, ...'
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
