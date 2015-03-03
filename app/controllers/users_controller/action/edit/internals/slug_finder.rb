
require 'action_support/slug_finder'

# UsersController: actions related to Users within our "fancy" blog.
class UsersController < ApplicationController
  module Action
    # Edit-user domain-logic setup verifies that a user is logged in.
    class Edit
      # Internal support code for UsersController::Action::Edit class.
      module Internals
        # Search repository for record matching slug; return matching entity or
        # raise if no match found.
        class SlugFinder < ActionSupport::SlugFinder
        end # class UsersController::Action::Edit::Internals::SlugFinder
      end
    end # class UsersController::Action::Edit
  end
end # class UsersController
