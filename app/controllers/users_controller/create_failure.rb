
require_relative 'blocking_failure_redirector'
require_relative 'user_checker'

# Internal classes used by our UsersController.
class UsersController < ApplicationController
  # Contains internal modules/classes used by methods, e.g., #on_create_failure.
  module Internals
    # Contains internal modules/classes used by #on_create_failure.
    module CreateFailure
    end # module Internals::CreateFailure
    private_constant :CreateFailure
    include CreateFailure

    def user_for_create_failure(payload, controller)
      BlockingFailureRedirector.new(payload, controller).check
      @user = UserChecker.new(payload, controller).parse
    end
  end # module Internals
  private_constant :Internals
end # class ApplicationController
