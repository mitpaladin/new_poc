
require 'contracts'

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
      include Contracts

      INIT_CONTRACT_INPUTS = RespondTo[:instance_variable_set, :redirect_to,
                                       :render, :root_path]

      Contract INIT_CONTRACT_INPUTS => CreateFailure
      def initialize(controller)
        @post_setter = lambda do |dao|
          controller.instance_variable_set :@post, dao
        end
        @redirect_to = controller.method :redirect_to
        @render = controller.method :render
        @root_path = controller.method :root_path
        self
      end

      Contract RuntimeError => CreateFailure
      def respond_to(payload)
        failure_cause_for(payload).call(payload)
        self
      end

      private

      attr_reader :post_setter, :redirect_to, :render, :root_path

      Contract RuntimeError => RespondTo[:call]
      def failure_cause_for(payload)
        supported_causes = [
          UnregisteredUser,
          InvalidEntity,
          UnknownFailure
        ]

        supported_causes.detect do |cause|
          cause.applies? payload
        end.new instance_values
      end
    end
  end
end # class PostsController
