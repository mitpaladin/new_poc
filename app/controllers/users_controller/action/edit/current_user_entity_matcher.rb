
# UsersController: actions related to Users within our "fancy" blog.
class UsersController < ApplicationController
  module Action
    # Edit-user domain-logic setup verifies that a user is logged in.
    class Edit
      # Match current user with entity alleged to be current user. Fail if
      # match fails.
      class CurrentUserEntityMatcher
        def initialize(current_user:, entity:)
          @current_user = current_user
          @entity = entity
        end

        def match
          return self if current_user.name == entity.name
          fail_with_dump
        end

        private

        attr_reader :current_user, :entity

        def fail_with_dump
          error_data = {
            not_user: entity.name,
            current: current_user.name
          }
          fail Yajl.dump(error_data)
        end
      end # class UsersController::Action::Edit::CurrentUserEntityMatcher
    end # class UsersController::Action::Edit
  end
end # class UsersController
