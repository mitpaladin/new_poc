
require 'action_support/broadcaster'
require 'action_support/guest_user_access'
require 'action_support/slug_finder'

require_relative 'update/internals/not_author_failure'

# PostsController: actions related to Posts within our "fancy" blog.
class PostsController < ApplicationController
  # Isolating our Action classes within the controller they're associated with.
  module Action
    # Verifies that the current user is permitted to update a specified post.
    class Update
      # Internal support classes for the Update class
      module Internals
      end
      private_constant :Internals
      include Internals

      include ActionSupport::Broadcaster

      def initialize(slug:, post_data:, current_user:, repository:)
        @slug = slug
        @post_data = post_data
        @current_user = current_user
        @repository = repository
      end

      def execute
        prohibit_guest_access
        validate_slug
        verify_user_is_author
        validate_updated_attributes
        update_entity
        broadcast_success entity
        self
      rescue RuntimeError => e
        broadcast_failure e.message
      end

      private

      attr_reader :current_user, :entity, :post_data, :repository, :slug

      def post_data_for_update
        to_hash = if post_data.respond_to? :to_unsafe_h
                    :to_unsafe_h
                  else
                    :to_h
                  end
        post_data.send(to_hash).reject { |k, _v| k.to_sym == :post_status }
          .symbolize_keys
      end

      def prohibit_guest_access
        ActionSupport::GuestUserAccess.new(current_user).prohibit
      end

      def update_entity
        inputs = post_data_for_update
        result = repository.update identifier: slug, updated_attrs: inputs
        fail UpdateFailure.new(slug, inputs).to_yaml unless result.success?
        @entity = repository.find_by_slug(slug).entity
      end

      def validate_slug
        @entity = ActionSupport::SlugFinder.new(slug: slug,
                                                repository: repository)
                  .find
                  .entity
      end

      def validate_updated_attributes
        attribs = entity.attributes.to_hash.merge post_data_for_update
        new_entity = entity.class.new attribs
        fail YAML.dump(attribs) unless new_entity.valid?
        @entity = new_entity
      end

      def verify_user_is_author
        return if current_user.name == entity.author_name
        fail NotAuthorFailure.new(current_user_name: current_user.name,
                                  post: entity)
          .to_json
      end
    end # class PostsController::Action::Update
  end
end # class PostsController
