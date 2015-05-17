
require 'contracts'

# UsersController: actions related to Users within our "fancy" blog.
class UsersController < ApplicationController
  # Isolating our Action classes within the controller they're associate with.
  module Action
    # Wisper-based command object called by Users controller #new action.
    class Create
      # Verifies password meets length requirement; raises otherwise.
      class PasswordLengthVerifier
        include ActionSupport
        include Contracts

        LENGTH_UNDERFLOW = 7

        Contract HashOf[Symbol, Any] => PasswordLengthVerifier
        def initialize(attributes)
          @attributes = attributes
          self
        end

        Contract None => nil
        def verify
          return if password_set? && password_long_enough?
          ActionSupport::DataObjectFailure.new(attributes: attributes,
                                               messages: messages).fail
        end

        private

        attr_reader :attributes

        Contract None => Array[String]
        def messages
          ["Password must be longer than #{LENGTH_UNDERFLOW} characters"]
        end

        Contract None => String
        def password
          attributes.fetch :password, ''
        end

        Contract None => Bool
        def password_long_enough?
          password.strip.length > LENGTH_UNDERFLOW
        end

        Contract None => Bool
        def password_set?
          password.present?
        end
      end # class UsersController::Action::Create::PasswordLengthVerifier
    end # class UsersController::Action::Create
  end
end # class UsersController
