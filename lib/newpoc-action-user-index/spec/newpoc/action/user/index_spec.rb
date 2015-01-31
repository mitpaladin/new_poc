
require 'spec_helper'
require 'wisper_subscription'

describe Newpoc::Action::User::Index do
  let(:all_message) { 'WE HAZ IT ALL!!!!1!' }
  let(:repo) { FancyOpenStruct.new all: all_message }
  let(:subscriber) { WisperSubscription.new }

  it 'has a version number' do
    expect(Newpoc::Action::User::Index::VERSION).not_to be nil
  end

  context 'with default success-event identifier, it' do
    let(:command) { described_class.new repo }

    before :each do
      subscriber.define_message :success
      command.subscribe subscriber
      command.execute
    end

    it 'is successful' do
      expect(subscriber).to be_success
    end

    it 'is successful, with a payload from the repository #all method' do
      payload = subscriber.payload_for :success
      expect(payload).to eq [all_message]
    end
  end # context 'with default success-event identifier, it'

  context 'with a non-default success-event identifier, it receives the' do
    let(:success_event) { :whatever }
    let(:command) { described_class.new repo, success_event }

    before :each do
      subscriber.define_message success_event
      command.subscribe subscriber
      command.execute
    end

    it 'success-event broadcast' do
      expect(subscriber).to be_whatever
    end

    it 'same payload as with the default success-event identifier' do
      payload = subscriber.payload_for success_event
      expect(payload).to eq [all_message]
    end
  end # context 'with a non-default success-event identifier, it receives the'
end # describe Newpoc::Action::User::Index
