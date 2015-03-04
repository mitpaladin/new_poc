
require 'action_support/broadcaster'
require 'action_support/guest_user_access'
require 'action_support/slug_finder'

# PostsController: actions related to Posts within our "fancy" blog.
class PostsController < ApplicationController
  # Isolating our Action classes within the controller they're associated with.
  module Action
    # Verifies that the current user is permitted to edit a specified post.
    class Edit
      module Internals
        # Current user not author of specified post. Bitch about it, as JSON.
        class NotAuthorFailure
          def initialize(user_name:, post:)
            @user_name = user_name
            @post = post
          end

          def to_yaml
            YAML.dump(
              current_user_name: @user_name,
              author_name:       @post.author_name,
              post_slug:         @post.slug.to_s
            )
          end
        end # class Newpoc::Action::Post::Edit::Internals::NotAuthorFailure
      end
      private_constant :Internals
      include Internals

      include ActionSupport::Broadcaster

      def initialize(slug:, current_user:, repository:)
        @slug = slug
        @current_user = current_user
        @repository = repository
      end

      def execute
        prohibit_guest_access
        validate_slug
        verify_user_is_author
        broadcast_success entity
      rescue RuntimeError => e
        broadcast_failure e.message
      end

      private

      attr_reader :current_user, :entity, :repository, :slug

      def prohibit_guest_access
        ActionSupport::GuestUserAccess.new(current_user).prohibit
      end

      def validate_slug
        @entity = ActionSupport::SlugFinder.new(slug: slug,
                                                repository: repository)
                  .find
                  .entity
      end

      def verify_user_is_author
        return if current_user.name == entity.author_name
        fail NotAuthorFailure.new(user_name: current_user.name, post: entity)
          .to_yaml
      end
    end # class PostsController::Action::Edit
  end
end # class PostsController
