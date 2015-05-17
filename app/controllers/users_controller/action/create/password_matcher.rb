
require 'contracts'
# require 'action_support/data_object_failure'

# UsersController: actions related to Users within our "fancy" blog.
class UsersController < ApplicationController
  # Isolating our Action classes within the controller they're associate with.
  module Action
    # Wisper-based command object called by Users controller #new action.
    class Create
      # Match password/confirmation; raise error on mismatch.
      class PasswordMatcher
        include ActionSupport
        include Contracts

        Contract RespondTo[:to_hash] => PasswordMatcher
        def initialize(user_data)
          @user_data = user_data
          @password_mismatch_message = 'Password must match the password' \
            ' confirmation'
          self
        end

        Contract None => nil
        def match
          return if user_data[:password] == user_data[:password_confirmation] &&
                    user_data[:password].to_s.present?
          ActionSupport::DataObjectFailure.new(attributes: user_data,
                                               messages: messages).fail
        end

        private

        attr_reader :password_mismatch_message, :user_data

        Contract None => Array[String]
        def messages
          [password_mismatch_message]
        end
      end # class UsersController::Action::Create::PasswordMatcher
    end # class UsersController::Action::Create
  end
end # class UsersController
