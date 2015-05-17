
require 'contracts'

# PostsController: actions related to Posts within our "fancy" blog.
class PostsController < ApplicationController
  # A Responder responds to the reported result of an application action in an
  # implementation-appropriate manner.
  module Responder
    # Takes an enumeration of entities as input, creates an Array of DAO
    # instances and assigns that to an instance variable on the passed-in
    # controller, and returns.
    class IndexSuccess
      include Contracts

      INIT_CONTRACT_INPUTS = RespondTo[:instance_variable_set]

      Contract INIT_CONTRACT_INPUTS => IndexSuccess
      def initialize(controller)
        @posts_setter = lambda do |daos|
          controller.instance_variable_set :@posts, daos
        end
        self
      end

      Contract ArrayOf[Entity::Post] => IndexSuccess
      def respond_to(entities)
        daos = []
        entities.each { |entity| daos.push dao_for(entity) }
        posts_setter.call daos
        self
      end

      private

      attr_reader :posts_setter

      Contract Entity::Post => PostDao
      def dao_for(entity)
        repo.dao.find(entity.slug).tap do |dao|
          dao.extend PostDao::Presentation
        end
      end

      Contract None => PostRepository
      def repo
        @repo ||= PostRepository.new
      end
    end # class PostsController::Responder::IndexSuccess
  end
end # class PostsController
