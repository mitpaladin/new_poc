
require 'wisper'

require 'newpoc/action/post/show/version'

module Newpoc
  module Action
    module Post
      # Retrieves a Post on behalf of current user, for `new_poc`.
      class Show
        include Wisper::Publisher

        def initialize(target_slug, current_user, post_repository, options = {})
          @target_slug = target_slug
          @current_user = current_user
          @post_repository = post_repository
          @success_event = options.fetch :success, :success
          @failure_event = options.fetch :failure, :failure
        end

        def execute
          validate_slug
          verify_authorisation
          broadcast_success @entity
        rescue RuntimeError
          broadcast_failure target_slug
        end

        private

        attr_reader :current_user, :entity, :failure_event, :post_repository,
                    :success_event, :target_slug

        def broadcast_success(payload)
          broadcast success_event, payload
        end

        def broadcast_failure(payload)
          broadcast failure_event, payload
        end

        def validate_slug
          result = post_repository.find_by_slug target_slug
          @entity = result.entity
          return if result.success?
          fail target_slug
        end

        def verify_authorisation
          return if entity.published? || current_user.name == entity.author_name
          fail target_slug
        end
      end # end class Newpoc::Action::Post::Show
    end
  end
end
