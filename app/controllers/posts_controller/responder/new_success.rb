
require 'contracts'

# PostsController: actions related to Posts within our "fancy" blog.
class PostsController < ApplicationController
  # A Responder responds to the reported result of an application action in an
  # implementation-appropriate manner.
  module Responder
    # Takes a (presumably empty) entity as input, creates a DAO instance and
    # assigns that to an instance variable on the passed-in controller, and
    # returns.
    class NewSuccess
      include Contracts

      INIT_CONTRACT_INPUTS = RespondTo[:instance_variable_set]

      Contract INIT_CONTRACT_INPUTS => NewSuccess
      def initialize(controller)
        @post_setter = lambda do |dao|
          controller.instance_variable_set :@post, dao
        end
        self
      end

      Contract Entity::Post => NewSuccess
      def respond_to(entity)
        dao = dao_for entity
        post_setter.call dao
        self
      end

      private

      attr_reader :post_setter

      Contract Entity::Post => PostDao
      def dao_for(entity)
        repo.dao.new(entity.attributes.to_hash).tap do |dao|
          dao.extend PostDao::Presentation
        end
      end

      Contract None => PostRepository
      def repo
        @repo ||= PostRepository.new
      end
    end # class PostsController::Responder::NewSuccess
  end
end # class PostsController
