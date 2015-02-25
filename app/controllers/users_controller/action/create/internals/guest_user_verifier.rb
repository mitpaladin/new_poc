
require_relative 'data_object_failure'

# UsersController: actions related to Users within our "fancy" blog.
class UsersController < ApplicationController
  # Isolating our Action classes within the controller they're associate with.
  module Action
    # Wisper-based command object called by Users controller #new action.
    class Create
      module Internals
        # Verifies that specified current user is Guest User; raises otherwise.
        class GuestUserVerifier
          def initialize(current_user, guest_user_name = default_guest_name)
            @current_user = current_user
            @guest_user_name = guest_user_name
          end

          def verify
            return if current_user.name == guest_user_name
            DataObjectFailure.new(messages: [already_logged_in_message]).fail
          end

          private

          attr_reader :current_user, :guest_user_name

          def already_logged_in_message
            "Already logged in as #{current_user.name}!"
          end

          def default_guest_name
            'Guest User'
          end
        end # class UsersController::Action::...::Internals::GuestUserVerifier
      end
    end # class UsersController::Action::Create
  end
end # class UsersController
