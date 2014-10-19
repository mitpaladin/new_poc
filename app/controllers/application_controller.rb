
require 'current_user_identity'

# Main application controller. Hang things off here that are needed by multiple
# controllers (which all subclass this one).
class ApplicationController < ActionController::Base
  include Pundit

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # after_action :verify_authorized,  except: :index
  # after_action :verify_policy_scoped, only: :index

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

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

  def user_not_authorized
    flash[:error] = 'You are not authorized to perform this action.'
    redirect_to request.headers['Referer'] || root_path
  end
end
