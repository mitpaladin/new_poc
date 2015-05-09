
require 'contracts'

require 'action_support/broadcaster'

# SessionsController: actions related to Sessions (logging in and out)
class SessionsController < ApplicationController
  module Action
    # Domain logic, if any existed, for logging out a user would go here.
    class Destroy
      include ActionSupport::Broadcaster
      include Contracts

      Contract None => Destroy
      def execute
        broadcast_success :session_destroy
        self
      end
    end # class SessionsController::Action::Destroy
  end
end # class SessionsController
