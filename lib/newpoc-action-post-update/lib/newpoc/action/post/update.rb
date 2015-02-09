
require 'wisper'
require 'yajl/json_gem'

require 'newpoc/action/post/update/version'
require 'newpoc/action/post/update/guest_access_failure'
require 'newpoc/action/post/update/not_author_failure'
require 'newpoc/action/post/update/slug_not_found_failure'
require 'newpoc/action/post/update/post_data_filter'

module Newpoc
  module Action
    module Post
      # Verifies that the current user is permitted to update a specified post.
      class Update
        # Internal support classes for the Update class
        module Internals
        end
        private_constant :Internals
        include Internals
        include Wisper::Publisher

        # rubocop:disable Metrics/ParameterLists
        def initialize(slug, post_data, current_user, post_repository,
                       guest_user, options = {})
          @slug = slug
          @post_data = PostDataFilter.new(post_data).filter
          @current_user = current_user
          @post_repository = post_repository
          @guest_user = guest_user
          @success_event = options.fetch :success, :success
          @failure_event = options.fetch :failure, :failure
        end
        # rubocop:enable Metrics/ParameterLists

        def execute
          prohibit_guest_access
          validate_slug
          verify_user_is_author
          @entity = update_entity
          broadcast_success entity
        rescue RuntimeError => the_error
          broadcast_failure the_error.message
        end

        private

        attr_reader :failure_event, :success_event
        attr_reader :current_user, :entity, :guest_user, :post_data,
                    :post_repository, :slug

        def broadcast_success(payload)
          broadcast success_event, payload
        end

        def broadcast_failure(payload)
          broadcast failure_event, payload
        end

        def prohibit_guest_access
          return unless guest_user.name == current_user.name
          fail GuestAccessFailure.new(self).to_json
        end

        # NOTE: Assumption in effect: if we can *find* the post, we can *update*
        #       the post. Rationale: users other than the post author have been
        #       filtered out by the time this is called. Ergo, no cheecking
        #       result for call to `post_repository.update`, and no checking for
        #       validity of the retrieved post. If we get it from the repo and
        #       it's *not* valid, we've got Big Problems beyond this scope.
        def update_entity
          inputs = post_data
          inputs.delete :post_status
          post_repository.update slug, inputs
          post_repository.find_by_slug(slug).entity
        end

        def validate_slug
          result = post_repository.find_by_slug slug
          @entity = result.entity
          return if result.success?
          fail SlugNotFoundFailure.new(self).to_json
        end

        def verify_user_is_author
          return if current_user.name == entity.author_name
          fail NotAuthorFailure.new(current_user.name, entity).to_json
        end
      end # class Newpoc::Action::Post::Update
    end
  end
end
