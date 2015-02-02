
require 'wisper'
require 'yajl/json_gem'

require 'newpoc/action/session/new/version'

module Newpoc
  module Action
    module Session
      # New-session login encapsulation for `new_poc`.
      class New
        include Wisper::Publisher

        def initialize(current_user, user_repo, options = {})
          @current_user = current_user
          @user_repo = user_repo
          @success_event = options.fetch :success_event, :success
          @failure_event = options.fetch :failure_event, :failure
        end

        def execute
          verify_not_logged_in
          broadcast_success guest_user
        rescue RuntimeError
          broadcast_failure current_user
        end

        private

        attr_reader :current_user, :failure_event, :success_event, :user_repo

        def broadcast_success(payload)
          broadcast success_event, payload
        end

        def broadcast_failure(payload)
          broadcast failure_event, payload
        end

        def guest_user
          @guest_user ||= user_repo.guest_user.entity
        end

        def verify_not_logged_in
          fail current_user.name unless guest_user.name == current_user.name
        end
      end # end class Newpoc::Action::Session::New
    end
  end
end
