
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
    # 1. `:instance_variable_set`;
    # 2. `:redirect_to`;
    # 3. `:render`; and
    # 4. `:root_path`.
    #
    class CreateFailure
      class InvalidEntity
        def initialize(ivars = {})
          @post_setter = ivars.fetch 'post_setter'
          @render = ivars.fetch 'render'
        end

        def self.applies?(payload)
          payload_data = JSON.parse(payload.message).deep_symbolize_keys
          entity_attribs = [:title, :slug, :author_name, :body, :image_url]
          entity_attribs.detect { |k| payload_data.key? k }
        rescue RuntimeError
          false
        end

        def call(payload)
          attribs = JSON.parse(payload.message).deep_symbolize_keys
                    .reject { |k, _v| [:errors].include? k }
          post = Repository::Post.new.dao.new(attribs).tap do |p|
            p.extend(PostDao::Presentation).valid?
          end
          post_setter.call post
          render.call 'new'
        end

        private

        attr_reader :post_setter, :render
      end # class PostsController::Responder::CreateFailure::InvalidEntity
      private_constant :InvalidEntity
    end # class PostsController::Responder::CreateFailure
  end
end # class PostsController
