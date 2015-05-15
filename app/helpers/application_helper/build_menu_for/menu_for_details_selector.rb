
require 'contracts'

require_relative 'navbar_menu_for_details'
require_relative 'sidebar_menu_for_details'

module ApplicationHelper
  include Contracts
  include Contracts::Modules
  # Module containing the `#build_menu_for` application-helper method.
  module BuildMenuFor
    include Contracts
    include Contracts::Modules
    # Which settings module should be used for a MenuForBuilder instance?
    class MenuForDetailsSelector
      include Contracts
      include Contracts::Modules

      MENUBAR_SELECT_INPUT = Or[:navbar, :sidebar]
      MENUBAR_CONTRACT_OUTPUT = RespondTo[:container_classes, :separator_attrs]

      Contract MENUBAR_SELECT_INPUT => Module # MENUBAR_CONTRACT_OUTPUT
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
