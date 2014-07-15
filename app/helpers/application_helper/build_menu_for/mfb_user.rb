
require_relative 'navbar_menu_for_details'
require_relative 'sidebar_menu_for_details'

module ApplicationHelper
  # Module containing the `#build_menu_for` application-helper method.
  module BuildMenuFor
    # Encapsulate what we need to know here about a user: guest status and name
    class MFBUser
      def initialize(user_impl)
        @user = user_impl
      end

      def name
        @user.name
      end

      def registered?
        name != 'Guest User'
      end
    end # class ApplicationHelper::BuildMenuFor::MFBUser
  end # module ApplicationHelper::BuildMenuFor
end # module ApplicationHelper
