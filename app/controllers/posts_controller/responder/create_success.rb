
require 'post_dao'

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
      def initialize(controller)
        @redirect_to = controller.method :redirect_to
        @root_path = controller.method :root_path
        @post_setter = -> (dao) { controller.instance_variable_set :@post, dao }
      end

      def respond_to(payload)
        set_dao_ivar(payload)
        redirect_to_root
      end

      private

      attr_reader :post_setter, :redirect_to, :root_path

      def dao_from_entity(entity)
        PostDao.new(entity.attributes.to_hash).tap { |dao| dao.save }
      end

      def flash_options
        { flash: { success: 'Post added!' } }
      end

      def redirect_to_root
        redirect_to.call root_path.call, flash_options
      end

      def set_dao_ivar(entity)
        post_setter.call dao_from_entity(entity)
        self
      end
    end # class PostsController::Responder::CreateSuccess
  end
end # class PostsController
