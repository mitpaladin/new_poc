
require 'wisper'

require 'newpoc/action/user/new/version'

module Newpoc
  module Action
    module User
      # New-user controller-action encapsulation for `new_poc`.
      class New
        include Wisper::Publisher

        def initialize(current_user, user_repo, entity_class, options = {})
          @current_user = current_user
          @user_repo = user_repo
          @entity_class = entity_class
          @success_event = options.fetch :success_event, :success
          @failure_event = options.fetch :failure_event, :failure
        end

        def execute
          verify_not_logged_in
          broadcast_success success_payload
        rescue RuntimeError
          broadcast_failure current_user
        end

        private

        attr_reader :current_user, :entity_class, :user_repo
        attr_reader :failure_event, :success_event

        def broadcast_success(payload)
          broadcast success_event, payload
        end

        def broadcast_failure(payload)
          broadcast failure_event, payload
        end

        def guest_user
          @guest_user ||= user_repo.guest_user.entity
        end

        def success_payload
          entity_class.new({})
        end

        def verify_not_logged_in
          fail current_user.name unless guest_user.name == current_user.name
        end
      end
    end
  end
end
