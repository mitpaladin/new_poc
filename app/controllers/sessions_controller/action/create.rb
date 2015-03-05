
require 'action_support/broadcaster'

# SessionsController: actions related to Sessions (logging in and out)
class SessionsController < ApplicationController
  # Isolating our Action classes within the controller they're associated with.
  module Action
    # New-session user-authentication encapsulation.
    class Create
      include ActionSupport::Broadcaster

      def initialize(name:, password:, repository:)
        @name = name
        @password = password
        @repository = repository
      end

      def execute
        authenticate_user
        broadcast_success entity
      rescue RuntimeError => e
        broadcast_failure e.message
      end

      private

      attr_reader :entity, :name, :password, :repository

      def authenticate_user
        auth_params = authentication_params
        result = repository.authenticate(*auth_params)
        @entity = result.entity
        return if result.success?
        fail result.errors.first[:message]
      end

      def authentication_params
        [name.to_s.parameterize, password.to_s]
      end
    end # class SessionsController::Action::Create
  end
end # class SessionsController
