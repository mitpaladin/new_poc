
require 'spec_helper'

require 'destroy_session'

# Short and sweet. There are presently no parameters or failure case defined.

module Actions
  describe DestroySession do
    let(:subscriber) { BroadcastSuccessTester.new }
    let(:command) { described_class.new }

    before :each do
      command.subscribe subscriber
      command.execute
    end

    it 'is successful' do
      expect(subscriber).to be_successful
      expect(subscriber).not_to be_failure
    end

    describe 'is successful, broadcasting a payload with' do
      let(:payload) { subscriber.payload_for(:success).first }

      it ':success' do
        expect(payload).to be :success
      end
    end # describe 'is successful, broadcasting a StoreResult payload with'
  end # describe Actions::DestroySession
end # module Actions
