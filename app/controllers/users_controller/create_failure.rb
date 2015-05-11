
require_relative 'user_checker'

# Internal classes used by our UsersController.
class UsersController < ApplicationController
  include CreateFailure

  def user_for_create_failure(payload, controller)
    @user = UserChecker.new(payload, controller).parse
  end
end # class ApplicationController
