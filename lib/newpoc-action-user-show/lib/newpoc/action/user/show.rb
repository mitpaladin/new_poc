
require 'wisper'
require 'wisper_subscription'

require 'newpoc/action/user/show/version'

module Newpoc
  module Action
    module User
      # Retrieves a user entity from the repository; part of `new_poc`.
      class Show
        include Wisper::Publisher

        def initialize(target_slug, user_repository, options = {})
          @target_slug = target_slug
          @user_repository = user_repository
          @success_event = options.fetch :success, :success
          @failure_event = options.fetch :failure, :failure
        end

        def execute
          validate_slug
          broadcast_success entity
        rescue RuntimeError
          broadcast_failure target_slug
        end

        private

        attr_reader :entity, :failure_event, :success_event, :target_slug,
                    :user_repository

        def broadcast_success(payload)
          broadcast success_event, payload
        end

        def broadcast_failure(payload)
          broadcast failure_event, payload
        end

        def validate_slug
          result = user_repository.find_by_slug target_slug
          @entity = result.entity
          return if result.success?
          fail target_slug
        end
      end # end class Newpoc::Action::User::Show
    end
  end
end
