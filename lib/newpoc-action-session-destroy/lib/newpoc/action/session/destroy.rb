
require 'wisper'

require 'newpoc/action/session/destroy/version'

module Newpoc
  module Action
    module Session
      # Domain/business-logic action for logging out a user.
      class Destroy
        include Wisper::Publisher

        # No-op for now. We *could* verify that the current user isn't the Guest
        # User, but YAGNI until we do (and until we pass the current user
        # identifier into the (not-yet-existing) #initialize method).
        def execute
          broadcast_success :success
        end

        private

        def broadcast_success(payload)
          broadcast :success, payload
        end
      end
    end
  end
end
