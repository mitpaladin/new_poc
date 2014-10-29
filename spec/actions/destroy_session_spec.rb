
require 'spec_helper'

require 'destroy_session'

# Short and sweet. There are presently no parameters or failure case defined.

module Actions
  describe DestroySession do
    let(:klass) { DestroySession }
    let(:subscriber) { BroadcastSuccessTester.new }
    let(:command) { klass.new }

    before :each do
      command.subscribe subscriber
      command.execute
    end

    it 'is successful' do
      expect(subscriber).to be_successful
      expect(subscriber).not_to be_failure
    end

    describe 'is successful, broadcasting a StoreResult payload with' do
      let(:payload) { subscriber.payload_for(:success).first }

      it 'a :success value of true' do
        expect(payload).to be_success
      end

      it 'an empty :errors item' do
        expect(payload.errors).to be_empty
      end

      it 'a nil :entity value' do
        expect(payload.entity).to be nil
      end
    end # describe 'is successful, broadcasting a StoreResult payload with'
  end # describe Actions::DestroySession
end # module Actions