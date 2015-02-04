
require 'newpoc/action/user/edit'
require 'newpoc/action/user/index'
require 'newpoc/action/user/new'
require 'newpoc/action/user/show'

require 'create_user'
require 'update_user'

require_relative 'users_controller/create_failure'

# UsersController: actions related to Users within our "fancy" blog.
class UsersController < ApplicationController
  include Internals

  def index
    action = Newpoc::Action::User::Index.new(UserRepository.new)
    action.subscribe(self, prefix: :on_index).execute
  end

  def new
    action = Newpoc::Action::User::New.new current_user, UserRepository.new,
                                           Newpoc::Entity::User
    action.subscribe(self, prefix: :on_new).execute
  end

  def create
    Actions::CreateUser.new(current_user, params[:user_data])
      .subscribe(self, prefix: :on_create).execute
  end

  def edit
    action = Newpoc::Action::User::Edit.new params[:id], current_user,
                                            UserRepository.new
    action.subscribe(self, prefix: :on_edit).execute
  end

  def show
    action = Newpoc::Action::User::Show.new params[:id], UserRepository.new
    action.subscribe(self, prefix: :on_show).execute
  end

  def update
    Actions::UpdateUser.new(params[:user_data], current_user)
      .subscribe(self, prefix: :on_update).execute
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

  def on_edit_success(payload) # rubocop:disable Style/TrivialAccessors
    @user = payload
  end

  # FIXME: Hackity hackity hack hack hack!
  def on_edit_failure(payload)
    alert = payload
    alert = "Not logged in as #{payload[:not_user]}!" if payload.key? :not_user
    redirect_to root_url, flash: { alert: alert }
  end

  def on_index_success(payload) # rubocop:disable Style/TrivialAccessors
    @users = payload
  end

  def on_new_success(payload) # rubocop:disable Style/TrivialAccessors
    @user = payload
  end

  def on_new_failure(payload)
    alert = "Already logged in as #{payload.name}!"
    redirect_to root_path, flash: { alert: alert }
  end

  def on_show_success(payload) # rubocop:disable Style/TrivialAccessors
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
    data = FancyOpenStruct.new JSON.parse(payload)
    @user = Newpoc::Entity::User.new data.entity if data.entity
    flash[:alert] = data.messages.join '<br/>'
    return render 'edit' if data.entity
    redirect_to root_path
  end
end # class UsersController
