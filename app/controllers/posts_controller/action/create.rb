
require 'contracts'

require_relative 'create/post_data_filter'
require 'action_support/broadcaster'
require 'action_support/entity_persister'
require 'action_support/guest_user_access'
require 'action_support/repository_adder'

# PostsController: actions related to Posts within our "fancy" blog.
class PostsController < ApplicationController
  # Isolating our Action classes within the controller they're associated with.
  module Action
    # Wisper-based command object called by Posts controller #create action.
    class Create
      include ActionSupport::Broadcaster
      include ActionSupport
      include Contracts

      INIT_CONTRACT_INPUTS = {
        current_user: UserDao,
        post_data: Hash,
        entity_class: Maybe[Class]
      }

      Contract INIT_CONTRACT_INPUTS => Create
      def initialize(current_user:, post_data:, entity_class: nil)
        filter = PostDataFilter.new(post_data)
        @post_data = filter.filter
        @draft_post = draft_post?
        @current_user = current_user
        @entity_class = entity_class || PostFactory.entity_class
        self
      end

      Contract None => Create
      def execute
        prohibit_guest_access
        validate_post_data
        add_entity_to_repository
        broadcast_success @entity
        self
      rescue RuntimeError => message_or_bad_entity
        broadcast_failure message_or_bad_entity
        self
      end

      private

      attr_reader :current_user, :draft_post, :entity, :entity_class, :post_data

      Contract None => Create
      def add_entity_to_repository
        params = {
          attributes: new_entity_attributes,
          repository: PostRepository.new,
          factory_class: PostFactory
        }
        @entity = RepositoryAdder.new(params).add.entity
        self
      end

      Contract None => Bool
      def draft_post?
        post_data[:pubdate].present?
      end

      Contract None => Hash
      def new_entity_attributes
        { author_name: current_user.name }.merge(post_data.to_h).tap do |ret|
          ret.store :pubdate, Time.zone.now if post_data.post_status == 'public'
        end
      end

      Contract None => GuestUserAccess
      def prohibit_guest_access
        GuestUserAccess.new(current_user).prohibit
      end

      Contract None => nil
      def validate_post_data
        @entity = entity_class.new new_entity_attributes
        return if @entity.valid?
        fail @entity.to_json
      end
    end # class PostsController::Action::Create
  end
end # class PostsController
