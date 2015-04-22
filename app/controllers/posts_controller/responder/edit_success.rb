
require 'post_dao'

# PostsController: actions related to Posts within our "fancy" blog.
class PostsController < ApplicationController
  # A Responder responds to the reported result of an application action in an
  # implementation-appropriate manner.
  module Responder
    # Takes an entity as input, assigns a (new) DAO instance to an instance
    # variable on the passed-in controller, and redirects.
    class EditSuccess
      def initialize(controller)
        @post_setter = -> (dao) { controller.instance_variable_set :@post, dao }
      end

      def respond_to(payload)
        assign_dao_ivar(payload)
      end

      private

      attr_reader :post_setter

      def dao_from_entity(entity)
        PostDao.new(entity.attributes.to_hash)
      end

      def assign_dao_ivar(entity)
        post_setter.call dao_from_entity(entity)
        self
      end
    end # class PostsController::Responder::EditSuccess
  end
end # class PostsController
