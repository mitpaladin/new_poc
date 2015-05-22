
require 'contracts'

require 'user'
require_relative 'build_menu_for/menu_for_details_selector'

module ApplicationHelper
  # Module containing the `#build_menu_for` application-helper method.
  module BuildMenuFor
    include Contracts
    include Contracts::Modules

    Contract Symbol, RespondTo[:name, :profile] => String
    def build_menu_for(which, current_user)
      if current_user.name == 'Guest User'
        GuestUser.new(self, which).markup
      else
        RegisteredUser.new(self, which, current_user).markup
      end
    end
  end # module ApplicationHelper::BuildMenuFor
end # module ApplicationHelper
