
require 'contracts'

# PostsController: actions related to Posts within our "fancy" blog.
class PostsController < ApplicationController
  # A Responder responds to the reported result of an application action in an
  # implementation-appropriate manner.
  module Responder
    # Takes an entity as input, retrieves the corresponding DAO instance,
    # assigns that to an instance variable on the passed-in controller, and
    # returns.
    class ShowSuccess
      include Contracts

      INIT_CONTRACT_INPUTS = RespondTo[:instance_variable_set]

      Contract INIT_CONTRACT_INPUTS => ShowSuccess
      def initialize(controller)
        @post_setter = lambda do |dao|
          controller.instance_variable_set :@post, dao
        end
        self
      end

      Contract RespondTo[:slug] => ShowSuccess
      def respond_to(entity)
        post_setter.call dao_for(entity)
        self
      end

      private

      attr_reader :post_setter

      Contract RespondTo[:slug] => PostDao
      def dao_for(entity)
        repo.dao.find(entity.slug).tap do |dao|
          dao.extend PostDao::Presentation
        end
      end

      Contract None => PostRepository
      def repo
        @repo ||= PostRepository.new
      end
    end # class PostsController::Responder::ShowSuccess
  end
end # class PostsController
