
require 'action_support/broadcaster'
require 'action_support/guest_user_access'

# SessionsController: actions related to Sessions (logging in and out)
class SessionsController < ApplicationController
  # Isolating our Action classes within the controller they're associated with.
  module Action
    # New-session login encapsulation. Prevent double login.
    class New
      include ActionSupport::Broadcaster

      def initialize(current_user:, user_repo:)
        @current_user = current_user
        @user_repo = user_repo
      end

      def execute
        verify_guest_user
        broadcast_success guest_user
      rescue RuntimeError
        broadcast_failure current_user
      end

      private

      attr_reader :current_user, :user_repo

      def guest_user
        user_repo.guest_user.entity
      end

      def verify_guest_user
        ActionSupport::GuestUserAccess.new(current_user).verify
      end
    end # class SessionsController::Action::New
  end
end # class SessionsController
