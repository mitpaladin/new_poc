
require 'action_support/data_object_failure'

# Supporting code used by and for controller-namespaced Action classes.
module ActionSupport
  # Enforces or prohibits access by Guest User, raising on violation.
  class GuestUserAccess
    def initialize(current_user, guest_user_name = default_guest_name)
      @current_user = current_user
      @guest_user_name = guest_user_name
    end

    def verify
      return self if current_user.name == guest_user_name
      DataObjectFailure.new(already_logged_in_errors).fail
    end

    def prohibit
      return self unless current_user.name == guest_user_name
      DataObjectFailure.new(not_logged_in_errors).fail
    end

    private

    attr_reader :current_user, :guest_user_name

    def already_logged_in_errors
      {
        messages: ["Already logged in as #{current_user.name}!"]
      }
    end

    def default_guest_name
      'Guest User'
    end

    def not_logged_in_errors
      {
        messages: ['Not logged in as a registered user!']
      }
    end
  end # class ActionSupport::GuestUserAccess
end # module ActionSupport
