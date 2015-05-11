
require 'contracts'

require 'action_support/slug_finder'

require_relative 'edit/current_user_entity_matcher'

# UsersController: actions related to Users within our "fancy" blog.
class UsersController < ApplicationController
  module Action
    # Edit-user domain-logic setup verifies that a user is logged in.
    class Edit
      include ActionSupport::Broadcaster
      include Contracts

      attr_reader :entity

      INIT_CONTRACT_INPUTS = {
        slug: String,
        current_user: RespondTo[:name],
        user_repository: RespondTo[:find_by_slug]
      }

      Contract INIT_CONTRACT_INPUTS => Edit
      def initialize(slug:, current_user:, user_repository:)
        @slug = slug
        @current_user = current_user
        @user_repository = user_repository
        self
      end

      Contract None => Edit
      def execute
        find_user_for_slug
        verify_current_user
        broadcast_success entity
        self
      rescue RuntimeError => error
        error_obj = Yajl.load error.message, symbolize_keys: true
        broadcast_failure error_obj
        self
      end

      private

      attr_reader :current_user, :slug, :user_repository

      Contract None => Entity::User
      def find_user_for_slug
        @entity = ActionSupport::SlugFinder.new(slug: slug,
                                                repository: user_repository)
                  .find.entity
      end

      Contract None => Any # raises an error on mismatch; else don't care
      def verify_current_user
        CurrentUserEntityMatcher.new(current_user: current_user, entity: entity)
          .match
      end
    end # class UsersController::Action::Edit
  end
end # class UsersController
