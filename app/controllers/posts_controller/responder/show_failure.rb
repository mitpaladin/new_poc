
# PostsController: actions related to Posts within our "fancy" blog.
class PostsController < ApplicationController
  # A Responder responds to the reported result of an application action in an
  # implementation-appropriate manner.
  module Responder
    # Takes a string (a slug) identifying a requested record/entity that does
    # not exist, stuffs it into an error message and redirects to the root path,
    # using the error message as an alert flash.
    #
    # Makes use of these methods on the controller passed into `#initialize`:
    #
    # 1. `:redirect_to`; and
    # 2. `:root_path`.
    #
    class ShowFailure
      def initialize(controller)
        @redirect_to = controller.method :redirect_to
        @root_path = controller.method :root_path
      end

      def respond_to(payload)
        @payload = payload
        redirect_to.call root_path.call, flash: { alert: alert }
      end

      private

      def alert
        "Cannot find post identified by slug: '#{payload}'!"
      end

      attr_reader :payload, :redirect_to, :root_path
    end # class PostsController::Responder::ShowFailure
  end
end # class PostsController
