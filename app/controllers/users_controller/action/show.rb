
require 'action_support/broadcaster'

# UsersController: actions related to Users within our "fancy" blog.
class UsersController < ApplicationController
  module Action
    # Retrieves a user entity based on a repository record.
    class Show
      include ActionSupport::Broadcaster
      attr_reader :entity

      def initialize(target_slug:, user_repository:)
        @target_slug = target_slug
        @user_repository = user_repository
      end

      def execute
        validate_slug
        broadcast_success entity
      rescue RuntimeError
        broadcast_failure target_slug
      end

      private

      attr_reader :target_slug, :user_repository

      def validate_slug
        result = user_repository.find_by_slug target_slug
        @entity = result.entity
        return if result.success?
        fail target_slug
      end
    end # class UsersController::Action::Show
  end
end # class UsersController
