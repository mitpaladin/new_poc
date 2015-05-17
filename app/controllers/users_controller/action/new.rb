
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

      Contract None => New
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

      Contract None => Class
      def entity_class
        UserFactory.entity_class
      end

      Contract None => Bool
      def guest_user?
        UserFactory.guest_user.name == current_user.name
      end

      Contract None => Entity::User
      def success_payload
        entity_class.new({})
      end

      Contract None => AlwaysRaises
      def verify_not_logged_in
        fail current_user.name unless guest_user?
      end
    end # class UsersController::Action::New
  end
end # class UsersController
