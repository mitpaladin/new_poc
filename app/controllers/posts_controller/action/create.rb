
require_relative 'create/internals/entity_persister'
require_relative 'create/internals/post_data_filter'
require 'action_support/broadcaster'
require 'action_support/guest_user_access'

# PostsController: actions related to Posts within our "fancy" blog.
class PostsController < ApplicationController
  # Isolating our Action classes within the controller they're associated with.
  module Action
    # Wisper-based command object called by Posts controller #create action.
    class Create
      # Internal classes used exclusively by PostsController::Action::Create.
      # (or should be...)
      module Internals
      end
      private_constant :Internals
      include Internals
      include ActionSupport::Broadcaster

      def initialize(current_user:, post_data:)
        filter = PostDataFilter.new(post_data)
        @post_data = filter.filter
        @draft_post = filter.draft_post
        @current_user = current_user
      end

      def execute
        prohibit_guest_access
        validate_post_data
        add_entity_to_repository
        broadcast_success @entity
      rescue RuntimeError => message_or_bad_entity
        broadcast_failure message_or_bad_entity
      end

      private

      attr_reader :current_user, :draft_post, :entity, :post_data

      def add_entity_to_repository
        persister_args = {
          attributes: post_data,
          repository: PostRepository.new
        }
        ActionSupport::EntityPersister.new(persister_args).persist do |attribs|
          PostFactory.create attribs
        end
      end

      def create_new_entity
        attribs = { author_name: current_user.name }.merge post_data.to_h
        Newpoc::Entity::Post.new attribs
      end

      def prohibit_guest_access
        ActionSupport::GuestUserAccess.new(current_user).prohibit
      end

      def validate_post_data
        @entity = create_new_entity
        return if @entity.valid?
        fail @entity.to_json
      end
    end # class PostsController::Action::Create
  end
end # class PostsController
