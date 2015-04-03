
# PostsController: actions related to Posts within our "fancy" blog.
class PostsController < ApplicationController
  # Internal classes exclusively used by PostsController.
  module Internals
    # Encapsulates processing after a failed create action.
    class CreateFailureSetup
      attr_reader :entity

      def initialize(payload)
        @payload_data = YAML.load(payload.message).symbolize_keys
      end

      def build
        @entity = build_entity
        @entity.valid?
        self
      end

      private

      attr_reader :payload_data

      def build_entity
        entity_class.new(entity_attributes).extend_with_validation
      end

      def entity_attributes
        payload_data[:original_attributes]
      end

      def entity_class
        PostFactory.entity_class
      end
    end # class PostsController::Internals::CreateFailureSetup
  end
end # class PostsController
