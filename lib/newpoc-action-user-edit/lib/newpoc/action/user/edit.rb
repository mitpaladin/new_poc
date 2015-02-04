
require 'wisper'
require 'yajl/json_gem'

require 'newpoc/action/user/edit/version'

module Newpoc
  module Action
    module User
      # Edit-user domain-logic setup verifies that a user is logged in.
      class Edit
        module Internals
          # There are two entirely separate ways that this action can fail:
          # 1. Not being logged in as the user matching the retrieved user; or
          # 2. The specified slug not matching a user in the repository.
          # Those will (probably) cause rather different error messages to be
          # reported via the UI (whatever that is).

          # This class is used to signal the first of the two errors above.
          class NotCurrentUserError
            def initialize(entity_user_name, current_user_name)
              @entity_user_name = entity_user_name
              @current_user_name = current_user_name
            end

            def to_json
              error = {
                not_user: @entity_user_name,
                current: @current_user_name
              }
              Yajl.dump error
            end
          end # class Newpoc::Action::User::Edit::Internals::NotCurrentUserError

          # This class is used to signal the second of the two errors above.
          class SlugError
            def initialize(slug)
              @slug = slug
            end

            def to_json
              error = { slug: @slug.to_s }
              Yajl.dump error
            end
          end # class Newpoc::Action::User::Edit::Internals::SlugError
        end # module Newpoc::Action::User::Edit::Internals
        private_constant :Internals
        include Internals

        include Wisper::Publisher

        def initialize(slug, current_user, user_repository, options = {})
          @slug = slug
          @current_user = current_user
          @user_repository = user_repository
          @success_event = options.fetch :success, :success
          @failure_event = options.fetch :failure, :failure
        end

        def execute
          find_user_for_slug
          verify_current_user
          broadcast_success @entity
        rescue RuntimeError => error
          error_obj = Yajl.load error.message, symbolize_keys: true
          broadcast_failure error_obj
        end

        private

        attr_reader :success_event, :failure_event
        attr_reader :current_user, :entity, :slug, :user_repository

        def broadcast_failure(payload)
          broadcast failure_event, payload
        end

        def broadcast_success(payload)
          broadcast success_event, payload
        end

        def find_user_for_slug
          result = user_repository.find_by_slug slug
          @entity = result.entity
          return if result.success?
          fail SlugError.new(slug).to_json
        end

        def verify_current_user
          return if current_user.name == entity.name
          fail NotCurrentUserError.new(entity.name, current_user.name).to_json
        end
      end # class Newpoc::Action::User::Edit
    end
  end
end
