
# require 'contracts'

require_relative 'basic_menu'

module ApplicationHelper
  # Module containing `ApplicationHelper#build_menu_for` and support classes.
  module BuildMenuFor
    class GuestUser
      include Contracts
      include BasicMenu

      Contract ViewHelper, Or[:navbar, :sidebar] => GuestUser
      def initialize(h, which)
        init_basic_menu h, which
        self
      end

      Contract None => String
      def markup
        build_container do
          build_item_for 'Sign up', href: h.new_user_path
          build_item_for 'Log in', href: h.new_session_path
        end
      end
    end # class ApplicationHelper::BuildMenuFor::GuestUser
  end
end
