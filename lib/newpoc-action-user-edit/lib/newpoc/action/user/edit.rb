
require 'wisper'

require 'newpoc/action/user/edit/version'

module Newpoc
  module Action
    module User
      # Edit-user domain-logic setup verifies that a user is logged in.
      class Edit
        include Wisper::Publisher

        def initialize(current_user, user_repository, options = {})
          @current_user = current_user
          @user_repository = user_repository
          @success_event = options.fetch :success, :success
          @failure_event = options.fetch :failure, :failure
        end

        def execute
          find_user_for_slug
          broadcast_success @entity
        rescue RuntimeError
          broadcast_failure current_user.slug
        end

        private

        attr_reader :current_user, :entity, :failure_event, :success_event,
                    :user_repository

        def broadcast_success(payload)
          broadcast success_event, payload
        end

        def broadcast_failure(payload)
          broadcast failure_event, payload
        end

        def find_user_for_slug
          result = user_repository.find_by_slug current_user.slug
          @entity = result.entity
          return if result.success?
          fail current_user.slug.to_s
        end
      end
    end
  end
end
