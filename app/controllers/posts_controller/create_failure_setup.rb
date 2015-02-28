
# PostsController: actions related to Posts within our "fancy" blog.
class PostsController < ApplicationController
  # Internal classes exclusively used by PostsController.
  module Internals
    # Encapsulates processing after a failed create action.
    class CreateFailureSetup
      attr_reader :entity

      def initialize(payload)
        @payload = payload
        @entity_class = Newpoc::Entity::Post
      end

      def cleanup
        fail_if_no_model_included
        @entity = rebuild_entity
        self
      end

      private

      attr_reader :entity_class, :payload

      def fail_if_no_model_included
        fail payload_data[:messages].first unless payload_data.key? :slug
      end

      def payload_data
        @payload_data ||= YAML.load(payload.message).symbolize_keys
      end

      def rebuild_entity
        entity = entity_class.new payload_data
        entity.valid?
        entity
      end
    end # class PostsController::Internals::CreateFailureSetup
  end
end # class PostsController
