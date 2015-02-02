
require 'wisper'

require 'newpoc/action/post/index/version'

module Newpoc
  module Action
    module Post
      # Business/domain logic to produce list of Posts viewable by current user.
      class Index
        include Wisper::Publisher

        def initialize(current_user, post_repository, success_event = :success)
          @current_user = current_user
          @post_repository = post_repository
          @success_event = success_event
        end

        def execute
          posts = post_repository.all.select { |post| should_include? post }
          broadcast_success posts
        end

        private

        attr_reader :current_user, :post_repository, :success_event

        def broadcast_success(payload)
          broadcast success_event, payload
        end

        def should_include?(post)
          return true if post.published?
          post.author_name == current_user.name
        end
      end # class Newpoc::Action::Post::Index
    end
  end
end
