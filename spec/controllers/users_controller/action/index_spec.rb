
require 'spec_helper'
require 'wisper_subscription'

describe UsersController::Action::Index do
  let(:all_message) { 'WE HAZ IT ALL!!!!1!' }
  let(:command) { described_class.new repo }
  let(:repo) { FancyOpenStruct.new all: all_message }
  let(:subscriber) { WisperSubscription.new }

  before :each do
    subscriber.define_message :success
    command.subscribe subscriber
    command.execute
  end

  it 'is successful, with a payload from the repository #all method' do
    expect(subscriber).to be_success
    payload = subscriber.payload_for :success
    expect(payload).to eq [all_message]
  end
end # describe UsersController::Action::Index
