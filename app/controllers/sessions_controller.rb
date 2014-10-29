
require 'create_session'
require 'new_session'

# SessionsController: actions related to Sessions (logging in and out)
class SessionsController < ApplicationController
  def new
    Actions::NewSession.new(current_user)
        .subscribe(self, prefix: :on_new)
        .execute
  end

  def create
    Actions::CreateSession.new(params[:name], params[:password])
        .subscribe(self, prefix: :on_create)
        .execute
  end

  def destroy
    # result = DSO2::SessionDestroyAction.run!
    # clear_current_user_id
    # redirect_to root_url, flash: flash_for_successful_logout
    authorise_current_user
    self.current_user = nil
    # update_current_user_id
    redirect_to root_url, flash: flash_for_successful_logout
  end

  # Action responders must be public to receive Wisper notifications; see
  # https://github.com/krisleech/wisper/issues/75 for relevant detail. Pffft.

  def on_create_success(payload)
    @errors = ErrorFactory.create []
    @user = payload.entity
    self.current_user = payload.entity
    redirect_to root_url, flash: flash_for_successful_login
  end

  def on_create_failure(payload)
    @user = payload.entity  # should be the Guest User
    redirect_to new_session_path, flash: flash_for_failed_login
  end

  def on_new_success(payload)
    @user = payload.entity
  end

  def on_new_failure(_payload)
    redirect_to root_path, flash: flash_for_logged_in_user
  end

  private # ################################################################## #

  # TODO: This should be a DSO, or at least a self-contained class.
  def authorise_current_user
    active_user = user_with_policy_class
    update_active_policy active_user
    authorize active_user
  end

  def flash_for_failed_login
    { alert: 'Invalid user name or password' }
  end

  def flash_for_logged_in_user
    { alert: "User '#{current_user.name}' is already logged in!" }
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
    self.current_user = user
    redirect_to root_url, flash: flash_for_successful_login
  end

  def update_active_policy(active_user)
    @policy = Pundit.policy(active_user, SessionData.new(id: 0))
  end

  def user_can_sign_in(user, password)
    user && user.authenticate(password)
  end

  def user_with_policy_class
    user = current_user
    user.instance_eval do
      def self.policy_class
        SessionDataPolicy
      end
    end
    self.current_user = user
  end
end
