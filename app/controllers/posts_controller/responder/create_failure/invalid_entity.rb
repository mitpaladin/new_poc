
require 'contracts'

# PostsController: actions related to Posts within our "fancy" blog.
class PostsController < ApplicationController
  # A Responder responds to the reported result of an application action in an
  # implementation-appropriate manner.
  module Responder
    # Takes an error-message string as input and redirects to the root path,
    # using the error message as an alert flash.
    #
    # Makes use of these methods on the controller passed into `#initialize`:
    #
    # 1. `:instance_variable_set` (via `post_setter'); and
    # 2. `:render`.
    #
    class CreateFailure
      class InvalidEntity
        include Contracts

        class InitContractInputs
          def self.valid?(value)
            return false unless value.respond_to? :to_hash
            ret = true
            %w(render post_setter).each do |key|
              ret &&= value.key?(key)
              ret &&= value[key].respond_to? :to_proc
              ret &&= value[key].to_proc.is_a?(Proc)
            end
            ret
          end

          def self.to_s
            '{"post_setter"=>Proc, "render"=>Proc[,others]}'
          end
        end

        # Contract can't only specify our two keys in a Hash, because that Hash
        # will contain other key/value pairs when called from non-spec code.
        Contract InitContractInputs => InvalidEntity
        def initialize(ivars)
          @post_setter = ivars.fetch 'post_setter'
          @render = ivars.fetch 'render'
          self
        end

        # The `payload` should be a RuntimeError with a JSON-serialised entity
        # in its `message`.
        Contract RuntimeError => Bool
        def self.applies?(payload)
          payload_data = JSON.parse(payload.message).deep_symbolize_keys
          entity_attribs = [:title, :slug, :author_name, :body, :image_url]
          entity_attribs.detect { |k| payload_data.key? k } ? true : false
        rescue JSON::ParserError # NOT a RuntimeError; tsk, tsk
          false
        end

        Contract RuntimeError => InvalidEntity
        def call(payload)
          attribs = attribs_from_message_in payload
          post = create_invalidated_post_dao attribs
          # post now has errors set (we wouldn't be here if it were valid)
          post_setter.call post
          # should render an empty string (for an invalid post)
          render.call 'new'
          self
        end

        private

        attr_reader :post_setter, :render

        Contract HashOf[Symbol, Maybe[String]] => PostDao
        def create_invalidated_post_dao(attribs)
          PostRepository.new.dao.new(attribs).tap do |p|
            p.extend(PostDao::Presentation).valid?
          end
        end

        Contract RuntimeError => HashOf[Symbol, Maybe[String]]
        def attribs_from_message_in(payload)
          JSON.parse(payload.message).symbolize_keys.reject do |k, _v|
            k == :errors
          end
        end
      end # class PostsController::Responder::CreateFailure::InvalidEntity
      private_constant :InvalidEntity
    end # class PostsController::Responder::CreateFailure
  end
end # class PostsController
