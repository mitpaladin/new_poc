
# require 'contracts'

require_relative 'menu_for_details_selector'

module ApplicationHelper
  # Module containing `ApplicationHelper#build_menu_for` and support classes.
  module BuildMenuFor
    class GuestUser
      include Contracts

      Contract ViewHelper, Or[:navbar, :sidebar] => GuestUser
      def initialize(h, which)
        extend MenuForDetailsSelector.new.select(which)
        @h = h
        self
      end
    end # class ApplicationHelper::BuildMenuFor::GuestUser
  end
end
