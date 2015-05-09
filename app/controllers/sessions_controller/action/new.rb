
require 'contracts'

require 'action_support/broadcaster'
require 'action_support/guest_user_access'

# SessionsController: actions related to Sessions (logging in and out)
class SessionsController < ApplicationController
  # Isolating our Action classes within the controller they're associated with.
  module Action
    # New-session login encapsulation. Prevent double login.
    class New
      include ActionSupport::Broadcaster
      include Contracts

      Contract RespondTo[:name] => New
      def initialize(current_user)
        @current_user = current_user
        self
      end

      Contract None => New
      def execute
        verify_guest_user
        broadcast_success guest_user
        self
      rescue RuntimeError
        broadcast_failure current_user
        self
      end

      private

      attr_reader :current_user

      def guest_user
        UserFactory.guest_user
      end

      def verify_guest_user
        ActionSupport::GuestUserAccess.new(current_user).verify
      end
    end # class SessionsController::Action::New
  end
end # class SessionsController
