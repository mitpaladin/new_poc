
require 'wisper'
require 'yajl/json_gem'

require 'newpoc/action/post/edit/version'

module Newpoc
  module Action
    module Post
      # Verifies that the current user is permitted to edit a specified post.
      class Edit
        module Internals
          # Build JSON based on source `slug` attribute.
          class SlugBasedError
            def initialize(source, error_key)
              the_slug = nil
              source.instance_eval { the_slug = slug }
              @slug = the_slug
              @error_key = error_key
            end

            def to_json
              {}.tap { |ret| ret[@error_key] = @slug }.to_json
            end
          end # class Newpoc::Action::Post::Edit::Internals::SlugBasedError

          # We don't allow Guests to edit posts. This JSON is what we broadcast.
          class GuestAccessFailure < SlugBasedError
            def initialize(source)
              super source, :guest_access_prohibited
            end
          end # class Newpoc::Action::Post::Edit::Internals::GuestAccessFailure

          # Specified slug isn't in the repo. Get JSON for error broadcast.
          class SlugNotFoundFailure < SlugBasedError
            def initialize(source)
              super source, :slug_not_found
            end
          end # class Newpoc::Action::Post::Edit::Internals::SlugNotFoundFailure

          # Current user not author of specified post. Bitch about it, as JSON.
          class NotAuthorFailure
            def initialize(current_user_name, post)
              @current_user_name = current_user_name
              @post = post
            end

            def to_json
              {
                current_user_name: @current_user_name,
                author_name:       @post.author_name,
                post_slug:         @post.slug.to_s
              }.to_json
            end
          end # class Newpoc::Action::Post::Edit::Internals::NotAuthorFailure
        end # module Newpoc::Action::Post::Edit::Internals
        private_constant :Internals
        include Internals

        include Wisper::Publisher

        def initialize(slug, current_user, post_repository, guest_user,
                       options = {})
          @slug = slug
          @current_user = current_user
          @post_repository = post_repository
          @guest_user = guest_user
          @success_event = options.fetch :success, :success
          @failure_event = options.fetch :failure, :failure
        end

        def execute
          prohibit_guest_access
          validate_slug
          verify_user_is_author
          broadcast_success entity
        rescue RuntimeError => the_error
          broadcast_failure the_error.message
        end

        private

        attr_reader :failure_event, :success_event
        attr_reader :current_user, :entity, :guest_user, :post_repository, :slug

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
      end # class Newpoc::Action::Post::Edit
    end
  end
end
