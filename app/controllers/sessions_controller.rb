
require 'create_session'
require 'destroy_session'
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
    Actions::DestroySession.new.subscribe(self, prefix: :on_destroy).execute
  end

  # Action responders must be public to receive Wisper notifications; see
  # https://github.com/krisleech/wisper/issues/75 for relevant detail.

  def on_create_success(payload)
    @errors = ErrorFactory.create []
    @user = payload.entity
    self.current_user = payload.entity
    redirect_to root_url, flash: { success: 'Logged in!' }
  end

  def on_create_failure(_payload)
    @user = nil
    flash_alert = { alert: 'Invalid user name or password' }
    redirect_to new_session_path, flash: flash_alert
  end

  def on_destroy_success(_payload)
    self.current_user = UserRepository.new.guest_user.entity
    redirect_to root_url, flash: { success: 'Logged out!' }
  end

  # No #on_destroy_failure. Can't happen and, even if it does, we don't want to
  # know about it. So there.

  def on_new_success(payload)
    @user = payload.entity
  end

  def on_new_failure(_payload)
    alert_flash = { alert: "User '#{current_user.name}' is already logged in!" }
    redirect_to root_path, flash: alert_flash
  end
end
