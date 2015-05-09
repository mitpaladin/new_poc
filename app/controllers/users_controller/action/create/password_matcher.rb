
require 'action_support/data_object_failure'

# UsersController: actions related to Users within our "fancy" blog.
class UsersController < ApplicationController
  # Isolating our Action classes within the controller they're associate with.
  module Action
    # Wisper-based command object called by Users controller #new action.
    class Create
      include Wisper::Publisher

      # Match password/confirmation; raise error on mismatch.
      class PasswordMatcher
        include ActionSupport

        def initialize(user_data)
          @user_data = user_data
          @password_mismatch_message = 'Password must match the password' \
            ' confirmation'
        end

        def match
          return if user_data[:password] == user_data[:password_confirmation]
          ActionSupport::DataObjectFailure.new(attributes: user_data,
                                               messages: messages).fail
        end

        private

        attr_reader :password_mismatch_message, :user_data

        def messages
          [password_mismatch_message]
        end
      end # class UsersController::Action::Create::PasswordMatcher
    end # class UsersController::Action::Create
  end
end # class UsersController
