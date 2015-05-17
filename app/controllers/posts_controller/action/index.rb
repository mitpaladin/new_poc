
require 'contracts'

require 'action_support/broadcaster'

# PostsController: actions related to Posts within our "fancy" blog.
class PostsController < ApplicationController
  # Isolating our Action classes within the controller they're associated with.
  module Action
    # Business/domain logic to produce list of Posts viewable by current user.
    class Index
      include ActionSupport::Broadcaster
      include Contracts

      INIT_CONTRACT_INPUTS = {
        current_user: UserDao,
        post_repository: RespondTo[:all]
      }

      Contract INIT_CONTRACT_INPUTS => Index
      def initialize(current_user:, post_repository:)
        @current_user = current_user
        @post_repository = post_repository
        self
      end

      Contract None => Index
      def execute
        broadcast_success permitted_posts
        self
      end

      private

      attr_reader :current_user, :post_repository

      Contract None => ArrayOf[Entity::Post]
      def permitted_posts
        post_repository.all.select { |post| should_include? post }
      end

      Contract Entity::Post => Bool
      def should_include?(post)
        post.published? || post.author_name == current_user.name
      end
    end # class PostsController::Action::Index
  end
end # class PostsController
