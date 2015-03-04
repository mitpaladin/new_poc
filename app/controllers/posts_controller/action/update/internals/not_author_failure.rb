
# PostsController: actions related to Posts within our "fancy" blog.
class PostsController < ApplicationController
  # Isolating our Action classes within the controller they're associated with.
  module Action
    # Verifies that the current user is permitted to update a specified post.
    class Update
      # Internal support classes for the Update class
      module Internals
        # Error raised when post author is not current user.
        class NotAuthorFailure
          def initialize(current_user_name:, post:)
            @current_user_name = current_user_name
            @post = post
          end

          def to_yaml
            data = {
              current_user_name: @current_user_name,
              author_name: @post.author_name
            }
            YAML.dump data
          end
        end # class PostsController::Action::Update::Internals::NotAuthorFailure
      end
    end # class PostsController::Action::Update
  end
end # class PostsController
