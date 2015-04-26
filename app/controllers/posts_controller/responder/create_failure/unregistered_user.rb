
# PostsController: actions related to Posts within our "fancy" blog.
class PostsController < ApplicationController
  # A Responder responds to the reported result of an application action in an
  # implementation-appropriate manner.
  module Responder
    # Takes an error-message string as input and redirects to the root path,
    # using the error message as an alert flash.
    #
    # Makes use of these methods on the controller passed into `#initialize`:
    #
    # 1. `:instance_variable_set`;
    # 2. `:redirect_to`;
    # 3. `:render`; and
    # 4. `:root_path`.
    #
    class CreateFailure
      class UnregisteredUser
        def initialize(ivars = {})
          # Rails' #instance_values returns a Hash with *String* keys
          @redirect_to = ivars.fetch 'redirect_to'
          @root_path = ivars.fetch 'root_path'
        end

        def self.alert
          'Not logged in as a registered user!'
        end

        def self.applies?(payload)
          data = YAML.load payload.message
          data == { messages: [alert] }
        rescue RuntimeError
          false
        end

        def call(*_args)
          redirect_to.call root_path.call, flash: { alert: self.class.alert }
        end

        private

        attr_reader :redirect_to, :root_path
      end # class PostsController::Responder::CreateFailure::UnregisteredUser
      private_constant :UnregisteredUser
    end # class PostsController::Responder::CreateFailure
  end
end # class PostsController
