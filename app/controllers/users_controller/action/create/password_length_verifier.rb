
require 'action_support/data_object_failure'

# UsersController: actions related to Users within our "fancy" blog.
class UsersController < ApplicationController
  # Isolating our Action classes within the controller they're associate with.
  module Action
    # Wisper-based command object called by Users controller #new action.
    class Create
      # Verifies password meets length requirement; raises otherwise.
      class PasswordLengthVerifier
        include ActionSupport

        def initialize(attributes, length_underflow = 7)
          @length_underflow = length_underflow
          @attributes = attributes
        end

        def verify
          return if password_set? && password_long_enough?
          ActionSupport::DataObjectFailure.new(attributes: attributes,
                                               messages: messages).fail
        end

        private

        attr_reader :attributes, :length_underflow

        def messages
          ["Password must be longer than #{length_underflow} characters"]
        end

        def password
          attributes.fetch :password, ''
        end

        def password_long_enough?
          password.strip.length > length_underflow
        end

        def password_set?
          password.present?
        end
      end # class UsersController::Action::Create::PasswordLengthVerifier
    end # class UsersController::Action::Create
  end
end # class UsersController
