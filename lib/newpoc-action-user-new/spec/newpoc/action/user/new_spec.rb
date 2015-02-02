
require 'spec_helper'

require 'fancy-open-struct'
require 'wisper_subscription'

describe Newpoc::Action::User::New do
  let(:command) do
    described_class.new user.name, user.password, repo, user_entity_class
  end
  let(:entity_class) { Hash }
  let(:guest_user) { FancyOpenStruct.new name: 'Guest User' }
  let(:registered_user) { FancyOpenStruct.new name: 'User Name' }
  let(:repo) do
    guest = FancyOpenStruct.new entity: guest_user
    FancyOpenStruct.new guest_user: guest
  end
  let(:subscriber) { WisperSubscription.new }

  it 'has a version number' do
    expect(Newpoc::Action::User::New::VERSION).not_to be nil
  end

  context 'with default option settings' do

    before :each do
      subscriber.define_message :success
      subscriber.define_message :failure
      command.subscribe subscriber
      command.execute
    end

    context 'when no user is currently logged in' do
      let(:command) { described_class.new guest_user, repo, entity_class }

      it 'broadcasts :success' do
        expect(subscriber).to be_success
      end

      describe 'broadcasts :success with a payload which' do
        let(:payload) { subscriber.payload_for(:success).first }

        it 'is an empty entity' do
          expect(payload.to_h).to be_empty
        end
      end # describe 'broadcasts :success with a payload which'
    end # context 'when no user is currently logged in'

    context 'when a registered user is logged in' do
      let(:command) { described_class.new registered_user, repo, entity_class }

      it 'broadcasts :failure' do
        expect(subscriber).to be_failure
      end

      describe 'broadcasts :failure with a payload which' do
        let(:payload) { subscriber.payload_for(:failure).first }

        it 'is an entity naming the currently logged-in user' do
          expect(payload.name).to eq registered_user.name
        end
      end # describe 'broadcasts :failure with a payload which'
    end # context 'when a registered user is logged in'
  end # context 'with default option settings'
end
