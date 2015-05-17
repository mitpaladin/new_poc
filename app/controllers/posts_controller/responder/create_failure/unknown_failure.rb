
require 'contracts'

# PostsController: actions related to Posts within our "fancy" blog.
class PostsController < ApplicationController
  # A Responder responds to the reported result of an application action in an
  # implementation-appropriate manner.
  module Responder
    # Takes a set of instance values for initialisation, and arbitrary data
    # passed to the `#call` method, and raises an "Unknown failure" error,
    # dumping the instance values and '#call' input data to the error message in
    # a human-readable format.
    class CreateFailure
      class UnknownFailure
        include Contracts

        Contract RespondTo[:to_hash] => UnknownFailure
        def initialize(ivars = {})
          @ivars = ivars
          self
        end

        Contract Any => true
        def self.applies?(_payload)
          true
        end

        Contract Any => Any
        def call(*args)
          message = "Unknown failure:\nargs: #{args.ai}\nivars: #{@ivars.ai}"
          fail message
        end
      end # class PostsController::Responder::CreateFailure::UnknownFailure
      private_constant :UnknownFailure
    end # class PostsController::Responder::CreateFailure
  end
end # class PostsController
