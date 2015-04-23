
require 'post_dao'

# PostsController: actions related to Posts within our "fancy" blog.
class PostsController < ApplicationController
  # A Responder responds to the reported result of an application action in an
  # implementation-appropriate manner.
  module Responder
    # Takes an entity as input, assigns a (new) DAO instance to an instance
    # variable on the passed-in controller, and redirects.
    class IndexSuccess
      def initialize(controller)
        @posts_setter = lambda do |daos|
          controller.instance_variable_set :@posts, daos
        end
      end

      def respond_to(entities)
        repo = PostRepository.new
        daos = []
        entities.each { |entity| daos.push repo.dao.find(entity.slug) }
        posts_setter.call daos
        self
      end

      private

      attr_reader :posts_setter
    end # class PostsController::Responder::IndexSuccess
  end
end # class PostsController
