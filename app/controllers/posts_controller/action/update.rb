
require 'contracts'

require 'action_support/broadcaster'
require 'action_support/guest_user_access'
require 'action_support/slug_finder'

require_relative 'update/not_author_failure'

# PostsController: actions related to Posts within our "fancy" blog.
class PostsController < ApplicationController
  # Isolating our Action classes within the controller they're associated with.
  module Action
    # Verifies that the current user is permitted to update a specified post.
    class Update
      private_constant :NotAuthorFailure

      include ActionSupport::Broadcaster
      include Contracts

      INIT_CONTRACT_INPUTS = {
        slug: String,
        post_data: Or[RespondTo[:to_unsafe_h], RespondTo[:to_hash]],
        current_user: UserDao,
        repository: RespondTo[:find_by_slug, :update]
      }

      Contract INIT_CONTRACT_INPUTS => Update
      def initialize(slug:, post_data:, current_user:, repository:)
        @slug = slug
        @post_data = post_data
        @current_user = current_user
        @repository = repository
        self
      end

      Contract None => Update
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
        self
      end

      private

      attr_reader :current_user, :entity, :post_data, :repository, :slug

      Contract None => HashOf[Symbol, Any]
      def post_attributes
        if post_data.respond_to? :to_unsafe_h # HashWithIndifferentAccess-like
          ret = post_data.to_unsafe_h
        elsif post_data.respond_to? :attributes # ActiveModel-like
          ret = post_data.attributes.to_hash
        else
          ret = post_data.to_hash
        end
        ret.symbolize_keys
      end

      Contract None => HashOf[Symbol, Any]
      def post_data_for_update
        post_attributes.reject { |k, _v| k.to_sym == :post_status }
          .symbolize_keys
      end

      Contract None => Update
      def prohibit_guest_access
        ActionSupport::GuestUserAccess.new(current_user).prohibit
        self
      end

      Contract None => Update
      def update_entity
        inputs = post_data_for_update
        result = repository.update identifier: slug, updated_attrs: inputs
        fail UpdateFailure.new(slug, inputs).to_yaml unless result.success?
        @entity = repository.find_by_slug(slug).entity
        self
      end

      Contract None => Update
      def validate_slug
        @entity = ActionSupport::SlugFinder.new(slug: slug,
                                                repository: repository)
                  .find
                  .entity
        self
      end

      Contract None => Update
      def validate_updated_attributes
        attribs = entity.attributes.to_hash.merge post_data_for_update
        new_entity = entity.class.new attribs
        fail YAML.dump(attribs) unless new_entity.valid?
        @entity = new_entity
        self
      end

      Contract None => Update
      def verify_user_is_author
        return self if current_user.name == entity.author_name
        fail NotAuthorFailure.new(current_user_name: current_user.name,
                                  post: entity)
          .to_json
      end
    end # class PostsController::Action::Update
  end
end # class PostsController
