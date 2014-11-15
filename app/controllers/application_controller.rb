
require 'current_user_identity'

# Main application controller. Hang things off here that are needed by multiple
# controllers (which all subclass this one).
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def current_user=(new_user) # rubocop:disable Rails/Delegate
    identity.current_user = new_user
  end
  helper_method :current_user=

  def current_user # rubocop:disable Rails/Delegate
    identity.current_user
  end
  helper_method :current_user

  private

  def identity
    @identity ||= CurrentUserIdentity.new(session)
  end
end
