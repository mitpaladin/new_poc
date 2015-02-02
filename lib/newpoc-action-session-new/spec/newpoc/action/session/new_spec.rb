
require 'spec_helper'

require 'wisper_subscription'

describe Newpoc::Action::Session::New do
  let(:command) do
    described_class.new user.name, user.password, repo
  end
  let(:subscriber) { WisperSubscription.new }
  let(:guest_user) { FancyOpenStruct.new name: 'Guest User' }
  let(:registered_user) { FancyOpenStruct.new name: 'User Name' }
  let(:repo) do
    guest = FancyOpenStruct.new entity: guest_user
    FancyOpenStruct.new guest_user: guest
  end

  it 'has a version number' do
    expect(Newpoc::Action::Session::New::VERSION).not_to be nil
  end

  context 'with default option settings' do

    before :each do
      subscriber.define_message :success
      subscriber.define_message :failure
      command.subscribe subscriber
      command.execute
    end

    context 'when no user is currently logged in' do
      let(:command) { described_class.new guest_user, repo }

      it 'broadcasts :success' do
        expect(subscriber).to be_success
      end

      describe 'broadcasts :success with a payload which' do
        let(:payload) { subscriber.payload_for(:success).first }

        it 'is a Guest User entity' do
          expect(payload.name).to eq 'Guest User'
        end
      end # describe 'broadcasts :success with a payload which'
    end # context 'when no user is currently logged in'

    context 'when a registered user is logged in' do
      let(:command) { described_class.new registered_user, repo }

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
