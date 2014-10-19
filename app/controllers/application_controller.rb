
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

  def current_user=(new_user)
    new_user ||= Naught.build.new   # call anything, get back nil
    self.logged_in_user_id = new_user.slug
  end
  helper_method :current_user=

  def current_user
    UserData.find logged_in_user_id
    # ret = UserData.find(session[:user_id]) if session[:user_id]
    # ret || UserData.find_by_name('Guest User')
  end
  helper_method :current_user

  def logged_in_user_id=(slug)
    session[:user_id] = slug || UserData.first.slug
  end

  def logged_in_user_id
    session[:user_id] ||= UserData.first.slug
    # NEW
    # session[:user_id] ||= UserRepository.new
    #     .guest_user(:no_password).entity.slug
  end

  private

  def user_not_authorized
    flash[:error] = 'You are not authorized to perform this action.'
    redirect_to request.headers['Referer'] || root_path
  end
end
