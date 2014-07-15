
# Main application controller. Hang things off here that are needed by multiple
# controllers (which all subclass this one).
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  private

  def current_user
    @current_user ||= UserData.find(session[:user_id]) if session[:user_id]
    @current_user ||= UserData.find_by_name 'Guest User'
  end
  helper_method :current_user
end
