
require 'action_support/broadcaster'
require 'action_support/guest_user_access'

# PostsController: actions related to Posts within our "fancy" blog.
class PostsController < ApplicationController
  # Isolating our Action classes within the controller they're associated with.
  module Action
    # New-post (pre-edit-attributes) encapsulation. Creates an empty entity.
    class New
      include ActionSupport::Broadcaster

      def initialize(current_user:, entity_class:, repository:)
        @current_user = current_user
        @repository = repository
        @entity_class = entity_class
      end

      def execute
        prohibit_guest_access
        broadcast_success build_entity
      rescue RuntimeError => e
        broadcast_failure failure_message_from(e.message)
      end

      private

      attr_reader :current_user, :entity_class, :repository

      def build_entity
        entity_class.new author_name: current_user.name
      end

      def failure_message_from(payload)
        error_data = YAML.load(payload)
        error_data[:messages].first
      end

      def prohibit_guest_access
        ActionSupport::GuestUserAccess.new(current_user).prohibit
      end
    end # class PostsController::Action::New
  end
end # class PostsController
