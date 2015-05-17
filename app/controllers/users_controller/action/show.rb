
require 'contracts'

require 'action_support/broadcaster'

# UsersController: actions related to Users within our "fancy" blog.
class UsersController < ApplicationController
  module Action
    # Retrieves a user entity based on a repository record.
    class Show
      include ActionSupport::Broadcaster
      include Contracts

      attr_reader :entity

      INIT_CONTRACT_INPUTS = {
        target_slug: String,
        user_repository: RespondTo[:find_by_slug]
      }

      Contract INIT_CONTRACT_INPUTS => Show
      def initialize(target_slug:, user_repository:)
        @target_slug = target_slug
        @user_repository = user_repository
        self
      end

      Contract None => Show
      def execute
        validate_slug
        broadcast_success entity
        self
      rescue RuntimeError
        broadcast_failure target_slug
        self
      end

      private

      attr_reader :target_slug, :user_repository

      Contract None => Show
      def validate_slug
        result = user_repository.find_by_slug target_slug
        @entity = result.entity
        return self if result.success?
        fail target_slug
      end
    end # class UsersController::Action::Show
  end
end # class UsersController
