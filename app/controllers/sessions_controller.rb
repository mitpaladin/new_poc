
require 'newpoc/action/session/destroy'

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
    action = Newpoc::Action::Session::Destroy.new
    action.subscribe(self, prefix: :on_destroy).execute
  end

  # Action responders must be public to receive Wisper notifications; see
  # https://github.com/krisleech/wisper/issues/75 for relevant detail.

  def on_create_success(payload)
    @user = payload
    self.current_user = @user
    redirect_to root_url, flash: { success: 'Logged in!' }
  end

  def on_create_failure(payload)
    @user = nil
    redirect_to new_session_path, flash: { alert: payload }
  end

  def on_destroy_success(_payload)
    self.current_user = UserRepository.new.guest_user.entity
    redirect_to root_url, flash: { success: 'Logged out!' }
  end

  # No #on_destroy_failure. Can't happen and, even if it does, we don't want to
  # know about it. So there.

  def on_new_success(payload) # rubocop:disable Style/TrivialAccessors
    @user = payload
  end

  def on_new_failure(payload)
    redirect_to root_path, flash: { alert: payload }
  end
end
