
require 'wisper'

require 'newpoc/action/post/new/version'

module Newpoc
  module Action
    module Post
      # New-post (pre-edit-attributes) encapsulation for `new_poc`.
      class New
        include Wisper::Publisher

        def initialize(current_user, repo, entity_class, options = {})
          @current_user = current_user
          @user_repository = repo
          @entity_class = entity_class
          @success_event = options.fetch :success, :success
          @failure_event = options.fetch :failure, :failure
        end

        def execute
          prohibit_guest_access
          broadcast_success build_entity
        rescue RuntimeError => the_error
          broadcast_failure the_error.message
        end

        private

        attr_reader :current_user, :entity_class, :failure_event,
                    :success_event, :user_repository

        def broadcast_failure(payload)
          broadcast failure_event, payload
        end

        def broadcast_success(payload)
          broadcast success_event, payload
        end

        def build_entity
          entity_class.new author_name: current_user.name
        end

        def prohibit_guest_access
          guest_user = user_repository.guest_user.entity
          return unless guest_user.name == current_user.name
          fail guest_user_not_authorised_message
        end

        def guest_user_not_authorised_message
          'Not logged in as a registered user!'
        end
      end # end class Newpoc::Action::Post::New
    end
  end
end
