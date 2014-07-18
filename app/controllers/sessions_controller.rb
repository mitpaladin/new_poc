
# SessionsController: actions related to Sessions (logging in and out)
class SessionsController < ApplicationController
  def new
    authorise_current_user
  end

  def create
    requesting_user = UserData.find_by_name params[:name]
    authorise_current_user
    if user_can_sign_in requesting_user, params[:password]
      setup_successful_login requesting_user
    else
      setup_failed_login requesting_user
    end
  end

  def destroy
    authorise_current_user
    update_current_user_id
    redirect_to root_url, flash: flash_for_successful_logout
  end

  private

  # TODO: This should be a DSO, or at least a self-contained class.
  def authorise_current_user
    active_user = user_with_policy_class
    update_active_policy active_user
    authorize active_user
  end

  def flash_for_failed_login
    { alert: 'Invalid user name or password' }
  end

  def flash_for_successful_login
    { success: 'Logged in!' }
  end

  def flash_for_successful_logout
    { success: 'Logged out!' }
  end

  def setup_failed_login(_user)
    redirect_to new_session_url, flash: flash_for_failed_login
  end

  def setup_successful_login(user)
    update_current_user_id user.id
    redirect_to root_url, flash: flash_for_successful_login
  end

  def update_active_policy(active_user)
    @policy = Pundit.policy(active_user, SessionData.new(id: 0))
  end

  def update_current_user_id(id = UserData.first.id)
    session[:user_id] = id
  end

  def user_can_sign_in(user, password)
    user && user.authenticate(password)
  end

  def user_with_policy_class
    user = current_user       # remember, #current_user is a query method
    user.instance_eval do
      def self.policy_class
        SessionDataPolicy
      end
    end
    user
  end
end
