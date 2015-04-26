
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
      class UnknownFailure
        def initialize(ivars = {})
          @ivars = ivars
        end

        def self.applies?(_payload)
          true
        end

        def call(*args)
          message = "Unknown failure:\nargs: #{args.ai}\nivars #{@ivars.ai}"
          fail message
        end
      end # class PostsController::Responder::CreateFailure::UnknownFailure
      private_constant :UnknownFailure
    end # class PostsController::Responder::CreateFailure
  end
end # class PostsController
