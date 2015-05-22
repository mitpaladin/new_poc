
# require 'contracts'

require_relative 'basic_menu'

module ApplicationHelper
  # Module containing `ApplicationHelper#build_menu_for` and support classes.
  module BuildMenuFor
    class RegisteredUser
      include Contracts
      include BasicMenu

      Contract ViewHelper, Or[:navbar, :sidebar],
               RespondTo[:name] => RegisteredUser
      def initialize(h, which, current_user)
        init_basic_menu h, which
        @current_user = current_user
        self
      end

      Contract None => String
      def markup
        build_container do
          build_item_for 'View your profile', href: user_profile_path
          build_separator_item
          build_item_for 'Log out', logout_params
        end
      end

      private

      attr_reader :current_user

      Contract None => Hash
      def logout_params
        {
          href: '/sessions/current',
          rel:  'nofollow'
        }.tap { |h| h['data-method'] = 'delete' }
      end

      Contract None => String
      def user_profile_path
        h.user_path(id: current_user.name.parameterize)
      end
    end # class ApplicationHelper::BuildMenuFor::RegisteredUser
  end
end
