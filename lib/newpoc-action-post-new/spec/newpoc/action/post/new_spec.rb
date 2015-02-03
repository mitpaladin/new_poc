
require 'spec_helper'

require 'fancy-open-struct'
require 'wisper_subscription'

describe Newpoc::Action::Post::New do
  let(:entity_class) { FancyOpenStruct }
  let(:guest_user) { FancyOpenStruct.new name: 'Guest User' }
  let(:registered_user) { FancyOpenStruct.new name: 'User Name' }
  let(:user_repo) do
    guest = FancyOpenStruct.new entity: guest_user
    FancyOpenStruct.new guest_user: guest
  end
  let(:subscriber) { WisperSubscription.new }

  it 'has a version number' do
    expect(Newpoc::Action::Post::New::VERSION).not_to be nil
  end

  context 'with default option settings' do
    let(:command) do
      described_class.new current_user, user_repo, entity_class
    end

    before :each do
      subscriber.define_message :success
      subscriber.define_message :failure
      command.subscribe subscriber
      command.execute
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
  end # context 'with default option settings'

  context 'with non-default option settings' do
    let(:command) do
      options = { success: :message_one, failure: :message_two }
      described_class.new current_user, user_repo, entity_class, options
    end

    before :each do
      subscriber.define_message :success
      subscriber.define_message :failure
      subscriber.define_message :message_one
      subscriber.define_message :message_two
      command.subscribe subscriber
      command.execute
    end

    context 'when a registeredc user is logged in' do
      let(:current_user) { registered_user }

      it 'broadcasts the specified event for success' do
        expect(subscriber).to be_message_one
      end

      it 'does not broadcast the default event for success' do
        expect(subscriber).not_to be_success
      end
    end # context 'when a registeredc user is logged in'

    context 'when no registered user is logged in' do
      let(:current_user) { guest_user }

      it 'broadcasts the specified event for failure' do
        expect(subscriber).to be_message_two
      end

      it 'does not broadcast the default event for failure' do
        expect(subscriber).not_to be_failure
      end
    end # context 'when no registered user is logged in'
  end # context 'with non-default option settings'
end
