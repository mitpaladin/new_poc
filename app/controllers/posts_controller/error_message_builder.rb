
# PostsController: actions related to Posts within our "fancy" blog.
class PostsController < ApplicationController
  module Internals
    # Build alert message for failed 'edit' or 'update' action.
    class ErrorMessageBuilder
      module Internals
        # Build appropriate error message if error data has matching key.
        class Message
          def initialize(key, &block)
            @key = key
            @callback = block
          end

          def key?(error_data)
            error_data.key? @key
          end

          def call(error_data)
            @callback.call error_data
          end
        end # class ...::Internals::ErrorMessageBuilder::Internals::Message
      end # module PostsController::Internals::ErrorMessageBuilder::Internals
      private_constant :Internals
      include Internals

      def initialize(payload)
        @error_data = nil
        begin
          @error_data = Yajl.load payload, symbolize_keys: true
        rescue Yajl::ParseError
          @error_data = YAML.load payload
        end
        build_matchers
      end

      def to_s
        matcher = matchers.find { |m| m.key? @error_data }
        return "Unknown error: no match for #{@error_data}" unless matcher
        matcher.call @error_data
      end

      private

      attr_reader :matchers

      def build_matchers
        @matchers = [
          self.class.require_user_matcher,
          self.class.bad_attributes_matcher,
          self.class.not_author_matcher
        ]
      end

      def self.bad_attributes_matcher
        Message.new(:created_at) do |error_data|
          entity = Newpoc::Entity::Post.new error_data
          entity.valid?
          entity.errors.full_messages.first
        end
      end

      def self.not_author_matcher
        Message.new(:current_user_name) do |error_data|
          bad_author = error_data[:current_user_name]
          "User #{bad_author} is not the author of this post!"
        end
      end

      def self.require_user_matcher
        Internals::Message.new(:guest_access_prohibited) do |_error_data|
          'Not logged in as a registered user!'
        end
      end
    end # class PostsController::Internals::ErrorMessageBuilder
  end # module PostsController::Internals
end # class PostsController
