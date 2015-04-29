
require 'post_dao'

# PostsController: actions related to Posts within our "fancy" blog.
class PostsController < ApplicationController
  # A Responder responds to the reported result of an application action in an
  # implementation-appropriate manner.
  module Responder
    # Takes an enumeration of entities as input, creates an Array of DAO
    # instances and assigns that to an instance variable on the passed-in
    # controller, and returns.
    class IndexSuccess
      def initialize(controller)
        @posts_setter = lambda do |daos|
          controller.instance_variable_set :@posts, daos
        end
      end

      def respond_to(entities)
        daos = []
        entities.each { |entity| daos.push dao_for(entity) }
        posts_setter.call daos
        self
      end

      private

      attr_reader :posts_setter

      def dao_for(entity)
        repo.dao.find(entity.slug).tap do |dao|
          dao.extend PostDao::Presentation
        end
      end

      def repo
        @repo ||= Repository::Post.new
      end
    end # class PostsController::Responder::IndexSuccess
  end
end # class PostsController
