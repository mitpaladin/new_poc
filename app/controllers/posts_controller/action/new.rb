
require 'contracts'

require 'action_support/broadcaster'
require 'action_support/guest_user_access'

# PostsController: actions related to Posts within our "fancy" blog.
class PostsController < ApplicationController
  # Isolating our Action classes within the controller they're associated with.
  module Action
    # New-post (pre-edit-attributes) encapsulation. Creates an empty entity.
    class New
      include ActionSupport::Broadcaster
      include Contracts

      INIT_CONTRACT_INPUTS = {
        current_user: UserDao,
        entity_class: Class,
        repository: Any # Do we really need this?
      }

      Contract INIT_CONTRACT_INPUTS => New
      def initialize(current_user:, entity_class:, repository:)
        @current_user = current_user
        @repository = repository
        @entity_class = entity_class
        self
      end

      Contract None => New
      def execute
        prohibit_guest_access
        broadcast_success build_entity
        self
      rescue RuntimeError => e
        broadcast_failure failure_message_from(e.message)
        self
      end

      private

      attr_reader :current_user, :entity_class, :repository

      Contract None => RespondTo[:attributes]
      def build_entity
        entity_class.new author_name: current_user.name
      end

      Contract String => String
      def failure_message_from(payload)
        error_data = YAML.load(payload)
        error_data[:messages].first
      end

      Contract None => ActionSupport::GuestUserAccess
      def prohibit_guest_access
        ActionSupport::GuestUserAccess.new(current_user).prohibit
      end
    end # class PostsController::Action::New
  end
end # class PostsController
