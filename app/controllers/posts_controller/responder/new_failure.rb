
require 'Contracts'

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
    # 1. `:redirect_to`; and
    # 2. `:root_path`.
    #
    class NewFailure
      include Contracts

      INIT_CONTRACT_INPUTS = RespondTo[:redirect_to, :root_path]

      Contract INIT_CONTRACT_INPUTS => NewFailure
      def initialize(controller)
        @redirect_to = controller.method :redirect_to
        @root_path = controller.method :root_path
        self
      end

      Contract String => NewFailure
      def respond_to(alert)
        redirect_to.call root_path.call, flash: { alert: alert }
        self
      end

      private

      attr_reader :redirect_to, :root_path
    end # class PostsController::Responder::NewFailure
  end
end # class PostsController
