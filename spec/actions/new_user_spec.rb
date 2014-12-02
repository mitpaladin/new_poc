
require 'spec_helper'

require 'new_user'

module Actions
  describe NewUser do
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
      let(:command) { described_class.new repo.guest_user.entity }

      it 'is successful' do
        expect(subscriber).to be_successful
        expect(subscriber).not_to be_failure
      end

      describe 'is successful, broadcasting a payload which' do
        let(:payload) { subscriber.payload_for(:success).first }

        it 'is an empty UserEntity' do
          expect(payload).to be_a UserEntity
          expect(payload.attributes).to be_empty
        end
      end # describe 'is successful, broadcasting a payload which'
    end # context 'with the Guest User as the current user'

    context 'with a Registered User as the current user' do
      let(:command) { described_class.new current_user }

      it 'is unsuccessful' do
        expect(subscriber).not_to be_successful
        expect(subscriber).to be_failure
      end

      describe 'is unsuccessful, broadcasting a payload which' do
        let(:payload) { subscriber.payload_for(:failure).first }
        let(:expected) { "Already logged in as #{current_user.name}!" }

        it 'is the correct error message' do
          expect(payload).to eq expected
        end
      end # describe 'is unsuccessful, broadcasting a payload which'
    end # context 'with a Registered User as the current user'
  end # describe Actions::NewUser
end # module Actions
