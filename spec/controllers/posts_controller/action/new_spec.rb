
require 'spec_helper'
require 'current_user_identity'
require 'support/broadcast_success_tester'

describe PostsController::Action::New do
  let(:command) do
    described_class.new current_user: current_user, repository: user_repo,
                        entity_class: entity_class
  end
  let(:entity_class) { FancyOpenStruct }
  let(:guest_user) { UserFactory.guest_user }
  let(:registered_user) { FancyOpenStruct.new name: 'User Name' }
  let(:user_repo) do
    guest = FancyOpenStruct.new entity: guest_user
    FancyOpenStruct.new guest_user: guest
  end
  let(:subscriber) { WisperSubscription.new }

  before :each do
    subscriber.define_message :success
    subscriber.define_message :failure
    command.subscribe(subscriber).execute
  end

  context 'when a registered user is logged in' do
    let(:current_user) { registered_user }

    it 'broadcasts :success' do
      expect(subscriber).to be_success
    end

    describe 'broadcasts :success with a payload which' do
      let(:payload) { subscriber.payload_for(:success).first }

      it 'is an entity with only an :author_name attribute' do
        expect(payload.author_name).to eq registered_user.name
        expect(payload.to_h.keys).to eq [:author_name]
      end
    end # describe 'broadcasts :success with a payload which'
  end # context 'when a registered user is logged in'

  context 'when no registered user is logged in' do
    let(:current_user) { guest_user }

    it 'broadcasts failure' do
      expect(subscriber).to be_failure
    end

    describe 'broadcasts :failure with a payload which' do
      let(:payload) { subscriber.payload_for(:failure).first }

      it 'is the correct error message' do
        expect(payload).to eq 'Not logged in as a registered user!'
      end
    end # describe 'broadcasts :failure with a payload which'
  end # context 'when no registered user is logged in'
end # describe PostsController::Action::New
