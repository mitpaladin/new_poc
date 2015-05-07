
require 'contracts'

require 'action_support/broadcaster'
require 'action_support/guest_user_access'
require 'action_support/slug_finder'

# PostsController: actions related to Posts within our "fancy" blog.
class PostsController < ApplicationController
  # Isolating our Action classes within the controller they're associated with.
  module Action
    # Retrieves a Post on behalf of current user, for `new_poc`.
    class Show
      include ActionSupport::Broadcaster
      include Contracts

      attr_reader :entity

      INIT_CONTRACT_INPUTS = {
        current_user: UserDao,
        repository: RespondTo[:find_by_slug],
        target_slug: String
      }

      Contract INIT_CONTRACT_INPUTS => Show
      def initialize(target_slug:, current_user:, repository:)
        @target_slug = target_slug
        @current_user = current_user
        @repository = repository
        self
      end

      Contract None => Show
      def execute
        @entity = validate_slug
        verify_authorisation
        broadcast_success entity
        self
      rescue RuntimeError
        broadcast_failure target_slug
        self
      end

      private

      attr_reader :current_user, :repository, :target_slug

      Contract None => Entity::Post
      def validate_slug
        ActionSupport::SlugFinder.new(slug: target_slug,
                                      repository: repository)
          .find.entity
      end

      Contract None => nil
      def verify_authorisation
        return if entity.published? || current_user.name == entity.author_name
        fail target_slug
      end
    end # class PostsController::Action::Show
  end
end # class PostsController
