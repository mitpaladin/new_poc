
require 'contracts'

# UsersController: actions related to Users within our "fancy" blog.
class UsersController < ApplicationController
  # Wraps error-message and redirect logic for Edit action failure.
  class EditFailureRedirector
    include Contracts

    INIT_CONTRACT_INPUTS = {
      payload: Hash,
      helper: RespondTo[:redirect_to, :root_url]
    }

    Contract INIT_CONTRACT_INPUTS => EditFailureRedirector
    def initialize(payload:, helper:)
      @payload = payload
      @helper = helper
      self
    end

    Contract None => Any
    def go
      helper.redirect_to helper.root_url, flash: { alert: alert }
    end

    private

    attr_reader :helper, :payload

    Contract None => Or[String, Hash]
    def alert
      return not_logged_in_message if not_logged_in?
      payload
    end

    Contract None => Bool
    def not_logged_in?
      payload.key? :not_user
    end

    Contract None => String
    def not_logged_in_message
      "Not logged in as #{payload[:not_user]}!"
    end
  end # class UsersController::Internals::EditFailureRedirector
end # class UsersController
