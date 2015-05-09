
require 'contracts'

require_relative 'password_length_verifier'
require_relative 'password_matcher'

# UsersController: actions related to Users within our "fancy" blog.
class UsersController < ApplicationController
  # Isolating our Action classes within the controller they're associate with.
  module Action
    # Wisper-based command object called by Users controller #new action.
    class Create
      # Verifies passwords meet both length/match criteria; raises otherwise.
      class PasswordVerifier
        include Contracts

        Contract HashOf[Symbol, Any] => PasswordVerifier
        def initialize(attributes)
          @attributes = attributes
          self
        end

        Contract None => PasswordVerifier
        def verify
          PasswordLengthVerifier.new(attributes).verify
          PasswordMatcher.new(attributes).match
          self
        end

        private

        attr_reader :attributes
      end # class UsersController::Action::Create::Internals::PasswordVerifier
    end # class UsersController::Action::Create
  end
end # class UsersController
