
require 'contracts'

# PostsController: actions related to Posts within our "fancy" blog.
class PostsController < ApplicationController
  # A Responder responds to the reported result of an application action in an
  # implementation-appropriate manner.
  module Responder
    # Takes an entity as input, assigns a (new) DAO instance to an instance
    # variable on the passed-in controller, and redirects.
    class EditSuccess
      include Contracts

      INIT_CONTRACT_INPUTS = RespondTo[:instance_variable_set]

      Contract INIT_CONTRACT_INPUTS => EditSuccess
      def initialize(controller)
        @post_setter = lambda do |dao|
          dao.extend PostDao::Presentation
          controller.instance_variable_set :@post, dao
        end
        self
      end

      Contract Entity::Post => EditSuccess
      def respond_to(payload)
        repo = PostRepository.new
        repo.update identifier: payload.slug,
                    updated_attrs: payload.attributes.to_hash
        post_setter.call repo.dao.find(payload.slug)
        self
      end

      private

      attr_reader :post_setter
    end # class PostsController::Responder::EditSuccess
  end
end # class PostsController
