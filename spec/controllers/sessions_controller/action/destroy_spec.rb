
# require 'spec_helper'
# require 'wisper_subscription'

# require 'sessions_controller/action/destroy'

# describe SessionsController::Action::Destroy do
#   let(:command) { described_class.new }
#   let(:subscriber) { WisperSubscription.new }

#   before :each do
#     subscriber.define_message :success
#     command.subscribe(subscriber).execute
#   end

#   # FIXME: This is temporarily commented out because RSpec gives a weird error
#   #        when it isn't. Further research is required.
#   xit 'is successful, returning a no-op payload of :success' do
#     expect(subscriber).to be_success
#     expect(subscriber.payload_for :success).to eq [:success]
#   end
# end # describe SessionsController::Action::Destroy
