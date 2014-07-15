
require_relative 'navbar_menu_for_details'
require_relative 'sidebar_menu_for_details'

module ApplicationHelper
  # Module containing the `#build_menu_for` application-helper method.
  module BuildMenuFor
    # Which settings module should be used for a MenuForBuilder instance?
    class MenuForDetailsSelector
      def select(which)
        if which == :navbar
          NavbarMenuForDetails
        elsif which == :sidebar
          SidebarMenuForDetails
        end # other value? Fall off; crash and burn; diagnose
      end
    end # class ApplicationHelper::BuildMenuFor::MenuForDetailsSelector
  end # module ApplicationHelper::BuildMenuFor
end # module ApplicationHelper
