
require 'contracts'

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
      include Contracts

      INIT_CONTRACT_INPUTS = RespondTo[:instance_variable_set, :post_path,
                                       :redirect_to]

      Contract INIT_CONTRACT_INPUTS => UpdateSuccess
      def initialize(controller)
        @redirect_to = controller.method :redirect_to
        @post_path = controller.method :post_path
        @post_setter = -> (dao) { controller.instance_variable_set :@post, dao }
        self
      end

      Contract RespondTo[:slug, :title] => UpdateSuccess
      def respond_to(payload)
        @post_title = payload.title
        assign_dao_ivar(payload)
        redirect_to_post
        self
      end

      private

      attr_reader :post_path, :post_setter, :post_title, :redirect_to

      Contract RespondTo[:slug] => PostDao
      def dao_from_entity(entity)
        repo.dao.find_by_slug(entity.slug).tap do |dao|
          dao.extend PostDao::Presentation
        end
      end

      Contract None => Hash
      def flash_options
        message = "Post '#{post_title}' successfully updated."
        { flash: { success: message } }
      end

      Contract None => UpdateSuccess
      def redirect_to_post
        redirect_to.call post_path.call, flash_options
        self
      end

      Contract RespondTo[:slug] => UpdateSuccess
      def assign_dao_ivar(entity)
        post_setter.call dao_from_entity(entity)
        self
      end

      Contract None => PostRepository
      def repo
        @repo ||= PostRepository.new
      end
    end # class PostsController::Responder::UpdateSuccess
  end
end # class PostsController
