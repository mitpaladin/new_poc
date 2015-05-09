
require 'spec_helper'
require 'wisper_subscription'

describe SessionsController::Action::New do
  describe 'has initialisation that' do
    it 'requires one parameter, which must respond to the :name message' do
      expect { described_class.new true }.to raise_error ParamContractError
      legal_user = FancyOpenStruct.new name: 'Anybody'
      expect { described_class.new legal_user }.not_to raise_error
    end
  end # describe 'has initialisation that'

  describe 'has an #execute method that' do
    let(:command) do
      described_class.new current_user
    end
    let(:guest_user_entity) { UserFactory.guest_user }
    let(:subscriber) { WisperSubscription.new }

    before :each do
      subscriber.define_message :success
      subscriber.define_message :failure
      command.subscribe(subscriber).execute
    end

    context 'when called after initialising with the Guest User' do
      let(:current_user) { guest_user_entity }

      it 'broadcasts :success, with a payload of the Guest User entity' do
        expect(subscriber).to be_success
        expect(subscriber.payload_for(:success).first).to be_guest_user
      end
    end

    context 'when called after initialising with a different user entity' do
      let(:current_user) { other_user_entity }
      let(:other_user_entity) { FancyOpenStruct.new name: 'Somebody Else' }

      it 'broadcasts :failure' do
        expect(subscriber).to be_failure
        expect(subscriber.payload_for(:failure).first).to be other_user_entity
      end
    end # context 'when called after initialising with a different user entity'
  end # describe 'has an #execute method that'
end # describe SessionsController::Action::New
