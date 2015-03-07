
require 'spec_helper'
require 'wisper_subscription'

describe SessionsController::Action::New do
  describe 'has initialisation that' do
    it 'requires two keyword parameters, :current_user and :user_repo' do
      args = { current_user: true, user_repo: true }
      expect { described_class.new args }.not_to raise_error
      args = { current_user: true }
      # NOTE: Error messages changed between Ruby 2.1 and Ruby 2.2; 2.1 would
      #       give the message 'missing keyword: user_repo' for the following
      #       test; Ruby 2.2 says 'wrong number of arguments (1 for 0)'. *NOT*
      #       '1 for 2', but '1 for 0'. WTF?
      expect do
        described_class.new true, args
      end.to raise_error ArgumentError
      args = { user_repo: true }
      expect do
        described_class.new true, args
      end.to raise_error ArgumentError
    end
  end # describe 'has initialisation that'

  describe 'has an #execute method that' do
    let(:command) do
      described_class.new current_user: current_user, user_repo: repo
    end
    let(:guest_user_entity) { FancyOpenStruct.new name: 'Guest User' }
    let(:repo) do
      Class.new do
        def initialize(guest)
          @guest = guest
        end

        def guest_user
          FancyOpenStruct.new entity: @guest
        end
      end.new(guest_user_entity)
    end
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
        expect(subscriber.payload_for(:success).first).to be guest_user_entity
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
