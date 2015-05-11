
require 'contracts'

# UsersController: actions related to Users within our "fancy" blog.
class UsersController < ApplicationController
  module Action
    # New-user controller-action encapsulation. Creates a new, empty entity.
    class New
      include ActionSupport::Broadcaster
      include Contracts

      INIT_CONTRACT_INPUTS = {
        current_user: RespondTo[:name]
      }

      # NOTE: Attire candidate
      Contract INIT_CONTRACT_INPUTS => New
      def initialize(current_user:)
        @current_user = current_user
        self
      end

      def execute
        verify_not_logged_in
        broadcast_success success_payload
        self
      rescue RuntimeError
        broadcast_failure current_user
        self
      end

      private

      attr_reader :current_user

      def entity_class
        UserFactory.entity_class
      end

      def guest_user?
        UserFactory.guest_user.name == current_user.name
      end

      def success_payload
        entity_class.new({})
      end

      def verify_not_logged_in
        fail current_user.name unless guest_user?
      end
    end # class UsersController::Action::New
  end
end # class UsersController
