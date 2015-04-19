
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

      def cleanup
        rebuild_entity
        fail_if_no_model_included
      end

      private

      attr_reader :payload_data

      def fail_if_no_model_included
        return self unless no_model_included? # if it's a message only
        @entity = nil
        fail payload_data[:messages].first
      end

      def no_model_included?
        attrs = entity.attributes.to_hash
        keys = attrs.keys.reject do |k|
          [:validation_context, :errors].include? k
        end
        keys.map { |k| attrs[k] }.reject(&:nil?).empty?
      end

      def rebuild_entity
        @entity = PostFactory.create(payload_data).tap(&:valid?)
        self
      end
    end # class PostsController::Internals::CreateFailureSetup
  end
end # class PostsController
