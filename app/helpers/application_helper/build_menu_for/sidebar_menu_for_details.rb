
module ApplicationHelper
  # Module containing the `#build_menu_for` application-helper method.
  module BuildMenuFor
    # Settings for MenuForBuilder to use when building a :sidebar menu
    module SidebarMenuForDetails
      def container_classes
        'nav nav-sidebar'
      end

      def separator_attrs
        {}
      end
    end # module ApplicationHelper::BuildMenuFor::SidebarMenuForDetails
  end # module ApplicationHelper::BuildMenuFor
end # module ApplicationHelper
