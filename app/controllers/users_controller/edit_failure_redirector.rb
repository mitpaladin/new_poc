
# UsersController: actions related to Users within our "fancy" blog.
class UsersController < ApplicationController
  # Wraps error-message and redirect logic for Edit action failure.
  class EditFailureRedirector
    def initialize(payload:, helper:)
      @payload = payload
      @helper = helper
    end

    def go
      helper.redirect_to helper.root_url, flash: { alert: alert }
    end

    private

    attr_reader :helper, :payload

    def alert
      return not_logged_in_message if not_logged_in?
      payload
    end

    def not_logged_in?
      payload.key? :not_user
    end

    def not_logged_in_message
      "Not logged in as #{payload[:not_user]}!"
    end
  end # class UsersController::Internals::EditFailureRedirector
end # class UsersController
