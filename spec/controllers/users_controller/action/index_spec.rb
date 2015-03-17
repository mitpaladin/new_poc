
require 'spec_helper'
require 'wisper_subscription'

describe UsersController::Action::Index do
  let(:all_messages) { ["No, I'm first!", "I'm first"] }
  let(:command) { described_class.new repo }
  let(:repo) { FancyOpenStruct.new all: all_messages }
  let(:subscriber) { WisperSubscription.new }

  before :each do
    subscriber.define_message :success
    command.subscribe subscriber
    command.execute
  end

  it 'is successful' do
    expect(subscriber).to be_success
  end

  describe 'is successful, with a payload' do
    let(:payload) { subscriber.payload_for(:success).first }

    it 'from the repository #all method' do
      expect(payload.sort).to eq all_messages.sort
    end

    it 'that is sorted' do
      expect(payload).to eq all_messages.sort
    end
  end # describe 'is successful, with a payload'
end # describe UsersController::Action::Index
