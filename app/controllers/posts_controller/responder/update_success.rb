
require 'post_dao'

# PostsController: actions related to Posts within our "fancy" blog.
class PostsController < ApplicationController
  # A Responder responds to the reported result of an application action in an
  # implementation-appropriate manner.
  module Responder
    # Takes an entity as input, assigns the corresponding saved DAO instance to
    # an instance variable on the passed-in controller, and redirects.
    #
    # Makes use of three methods on the controller passed into `#initialize`:
    #
    # 1. `instance_variable_set';
    # 2. `:redirect_to`; and
    # 3. `:post_path`.
    #
    class UpdateSuccess
      def initialize(controller)
        @redirect_to = controller.method :redirect_to
        @post_path = controller.method :post_path
        @post_setter = -> (dao) { controller.instance_variable_set :@post, dao }
      end

      def respond_to(payload)
        @post_title = payload.title
        assign_dao_ivar(payload)
        redirect_to_post
      end

      private

      attr_reader :post_path, :post_setter, :post_title, :redirect_to

      def dao_from_entity(entity)
        repo.dao.find_by_slug(entity.slug).tap do |dao|
          dao.extend PostDao::Presentation
        end
      end

      def flash_options
        message = "Post '#{post_title}' successfully updated."
        { flash: { success: message } }
      end

      def redirect_to_post
        redirect_to.call post_path.call, flash_options
      end

      def assign_dao_ivar(entity)
        post_setter.call dao_from_entity(entity)
        self
      end

      def repo
        @repo ||= Repository::Post.new
      end
    end # class PostsController::Responder::UpdateSuccess
  end
end # class PostsController
