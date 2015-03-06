
require_relative 'sessions_controller/action/create'
require_relative 'sessions_controller/action/destroy'
require_relative 'sessions_controller/action/new'

# SessionsController: actions related to Sessions (logging in and out)
class SessionsController < ApplicationController
  # Isolating our Action classes within the controller they're associated with.
  module Action
  end

  def new
    action = Action::New.new current_user: current_user,
                             user_repo: UserRepository.new
    action.subscribe(self, prefix: :on_new).execute
  end

  def create
    Action::Create.new(name: params[:name], password: params[:password],
                       repository: UserRepository.new)
      .subscribe(self, prefix: :on_create)
      .execute
  end

  def destroy
    Action::Destroy.new.subscribe(self, prefix: :on_destroy).execute
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

  def on_new_success(payload)
    @user = payload
  end

  def on_new_failure(payload)
    alert = "Already logged in as #{payload.name}!"
    redirect_to root_path, flash: { alert: alert }
  end
end
