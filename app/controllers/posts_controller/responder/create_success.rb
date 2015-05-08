
require 'contracts'

# PostsController: actions related to Posts within our "fancy" blog.
class PostsController < ApplicationController
  # A Responder responds to the reported result of an application action in an
  # implementation-appropriate manner.
  module Responder
    # Takes an entity as input, assigns a (new) DAO instance to an instance
    # variable on the passed-in controller, and redirects.
    #
    # Makes use of three methods on the controller passed into `#initialize`:
    #
    # 1. `instance_variable_set';
    # 2. `:redirect_to`; and
    # 3. `:root_path`.
    #
    class CreateSuccess
      include Contracts

      INIT_CONTRACT_INPUTS = RespondTo[:instance_variable_set, :redirect_to,
                                       :root_path]

      Contract INIT_CONTRACT_INPUTS => CreateSuccess
      def initialize(controller)
        @redirect_to = controller.method :redirect_to
        @root_path = controller.method :root_path
        @post_setter = -> (dao) { controller.instance_variable_set :@post, dao }
        self
      end

      Contract Entity::Post => CreateSuccess
      def respond_to(payload)
        assign_dao_ivar(payload)
        redirect_to_root
        self
      end

      private

      attr_reader :post_setter, :redirect_to, :root_path

      Contract Entity::Post => PostDao
      def dao_from_entity(entity)
        PostDao.new(entity.attributes.to_hash)
      end

      Contract None => Hash
      def flash_options
        { flash: { success: 'Post added!' } }
      end

      Contract None => CreateSuccess
      def redirect_to_root
        redirect_to.call root_path.call, flash_options
        self
      end

      Contract Entity::Post => CreateSuccess
      def assign_dao_ivar(entity)
        post_setter.call dao_from_entity(entity)
        self
      end
    end # class PostsController::Responder::CreateSuccess
  end
end # class PostsController
