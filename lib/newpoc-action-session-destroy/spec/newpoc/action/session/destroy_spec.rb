
require 'spec_helper'
require 'wisper_subscription'

describe Newpoc::Action::Session::Destroy do
  let(:command) { described_class.new }
  let(:subscriber) { WisperSubscription.new }

  before :each do
    subscriber.define_message :success
    command.subscribe subscriber
    command.execute
  end

  it 'has a version number' do
    expect(Newpoc::Action::Session::Destroy::VERSION).not_to be nil
  end

  it 'is successful, returning a no-op payload of :success' do
    expect(subscriber).to be_success
    expect(subscriber.payload_for :success).to eq [:success]
  end
end
