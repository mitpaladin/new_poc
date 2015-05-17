
# We really only need to require one file in each non-default directory to have
# the whole directory sucked into the auto-load pool, apparently.
require_relative 'users_controller/action/create'
require_relative 'users_controller/create_failure'

# UsersController: actions related to Users within our "fancy" blog.
class UsersController < ApplicationController
  include Internals

  def_action(:index) { UserRepository.new }

  def_action(:new) do
    { current_user: current_user }
  end

  def_action(:create) do
    { current_user: current_user, user_data: params[:user_data] }
  end

  def_action(:edit) do
    {
      slug: params[:id], current_user: current_user,
      user_repository: UserRepository.new
    }
  end

  def_action(:show) do
    { target_slug: params[:id], user_repository: UserRepository.new }
  end

  def_action(:update) do
    { user_data: params[:user_data], current_user: current_user }
  end

  # Action responders must be public to receive Wisper notifications; see
  # https://github.com/krisleech/wisper/issues/75 for relevant detail. (Needless
  # to say that, even though these are public methods, they should never be
  # called directly.)

  def on_create_success(payload)
    @user = payload
    redirect_to root_url, flash: { success: 'Thank you for signing up!' }
  end

  def on_create_failure(payload)
    @user = user_for_create_failure(payload, self)

    render 'new'
  end

  def on_edit_success(payload)
    @user = payload
  end

  def on_edit_failure(payload)
    EditFailureRedirector.new(payload: payload, helper: self).go
  end

  def on_index_success(payload)
    @users = payload
  end

  def on_new_success(payload)
    @user = payload
  end

  def on_new_failure(payload)
    alert = "Already logged in as #{payload.name}!"
    redirect_to root_path, flash: { alert: alert }
  end

  def on_show_success(payload)
    @user = payload
  end

  def on_show_failure(payload)
    alert = "Cannot find user identified by slug #{payload}!"
    redirect_to users_path, flash: { alert: alert }
  end

  def on_update_success(payload)
    @user = payload
    message = 'You successfully updated your profile'
    redirect_to user_path(@user.slug), flash: { success: message }
  end

  def on_update_failure(payload)
    data = FancyOpenStruct.new YAML.load(payload)
    @user = UserFactory.create data.entity if data.entity
    flash[:alert] = data.messages.join '<br/>'
    return render 'edit' if data.entity
    redirect_to root_path
  end
end # class UsersController
