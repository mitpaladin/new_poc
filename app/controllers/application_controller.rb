
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

  private

  def current_user
    @current_user ||= UserData.find(session[:user_id]) if session[:user_id]
    @current_user ||= UserData.find_by_name 'Guest User'
  end
  helper_method :current_user

  def user_not_authorized
    flash[:error] = 'You are not authorized to perform this action.'
    redirect_to request.headers['Referer'] || root_path
  end
end
