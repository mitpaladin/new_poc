
module ApplicationHelper
  # Module containing the `#build_menu_for` application-helper method.
  module BuildMenuFor
    # Settings for MenuForBuilder to use when building a :navbar menu.
    module NavbarMenuForDetails
      def container_classes
        'nav navbar-nav'
      end

      def separator_attrs
        { style: 'min-width: 3rem;' }
      end
    end # module ApplicationHelper::BuildMenuFor::NavbarMenuForDetails
  end # module ApplicationHelper::BuildMenuFor
end # module ApplicationHelper
