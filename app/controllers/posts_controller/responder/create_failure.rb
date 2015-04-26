
require 'awesome_print'

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

        def self.create_if_applies?(ivars, payload)
          self.class.new ivars
        end

        def call(*args)
          message = "Unknown failure:\nargs: #{args.ai}\nivars #{@ivars.ai}"
          fail message
        end
      end # class PostsController::Responder::CreateFailure::UnknownFailure

      class UnregisteredUser
        def initialize(ivars = {})
          # Rails' #instance_values returns a Hash with *String* keys
          @redirect_to = ivars.fetch 'redirect_to'
          @root_path = ivars.fetch 'root_path'
        end

        def self.alert
          'Not logged in as a registered user!'
        end

        def self.create_if_applies?(ivars, payload)
          return nil unless payload.respond_to?(:message) &&
            payload.message == alert
          new(ivars)
        end

        def call(*_args)
          redirect_to.call root_path.call, flash: { alert: self.class.alert }
        end

        private

        attr_reader :redirect_to, :root_path
      end # class PostsController::Responder::CreateFailure::UnregisteredUser

      def initialize(controller)
        @post_setter = lambda do |dao|
          controller.instance_variable_set :@post, dao
        end
        @redirect_to = controller.method :redirect_to
        @render = controller.method :render
        @root_path = controller.method :root_path
      end

      def respond_to(payload)
        # failure_cause_for(payload).call
        ap [:line_73, payload]
        obj = UnregisteredUser.create_if_applies?(instance_values, payload)
        obj.call
      end

      private

      attr_reader :post_setter, :redirect_to, :render, :root_path

      def failure_cause_for(payload)
        supported_causes = [
          UnregisteredUser,
          UnknownFailure,
        ]

        supported_causes.detect do |cause|
          cause.create_if_applies? payload, instance_values
        end
      end
    end

    # class OldCreateFailure
    #   def respond_to(payload)
    #     main_data = decode_payload(payload)
    #     # main_data[:entity] will have an entity instance if successful
    #     # main_data[:message] will have the passed-in error message otherwise
    #     if main_data.key? :entity
    #       attribs = main_data[:entity].attributes.to_hash
    #       post = PostRepository.new.dao.new(attribs).tap do |post|
    #         post.extend PostDao::Presentation
    #       end
    #       post.valid?
    #       @post_setter.call post
    #       render.call 'new'
    #     else
    #       redirect_to.call root_path.call, flash: { alert: main_data[:message] }
    #     end
    #   end

    #   private

    #   attr_reader :redirect_to, :render, :root_path

    #   def decode_payload(payload)
    #     payload_data = YAML.load(payload.message).deep_symbolize_keys
    #     # fail_if_no_model_included
    #     check_model payload_data
    #   end

    #   def check_model(payload_data) # fka #no_model_included?
    #     ret = {}
    #     # rebuild_entity
    #     entity = PostFactory.create(payload_data).tap(&:valid?)
    #     attrs = entity.attributes.to_hash
    #     keys = attrs.keys.reject do |k|
    #       [:validation_context, :errors].include? k
    #     end
    #     no_model = keys.map { |k| attrs[k] }.reject(&:nil?).empty?
    #     if no_model
    #       ret[:message] = payload_data[:messages].first
    #     else
    #       ret[:entity] = entity
    #     end
    #     ret
    #   end
    # end # class PostsController::Responder::OldCreateFailure
  end
end # class PostsController
