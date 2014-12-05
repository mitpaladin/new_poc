
require 'create_user'
require 'edit_user'
require 'index_users'
require 'new_user'
require 'show_user'
require 'update_user'

require_relative 'users_controller/create_failure'

# UsersController: actions related to Users within our "fancy" blog.
class UsersController < ApplicationController
  include Internals

  def index
    Actions::IndexUsers.new.subscribe(self, prefix: :on_index).execute
  end

  def new
    Actions::NewUser.new(current_user).subscribe(self, prefix: :on_new).execute
  end

  def create
    Actions::CreateUser.new(current_user, params[:user_data])
      .subscribe(self, prefix: :on_create).execute
  end

  def edit
    Actions::EditUser.new(params[:id], current_user)
      .subscribe(self, prefix: :on_edit).execute
  end

  def show
    Actions::ShowUser.new(params[:id]).subscribe(self, prefix: :on_show).execute
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
    # CreateFailure::BlockingFailureRedirector.new(payload, self).check
    # @user = CreateFailure::UserChecker.new(payload, self).parse
    render 'new'
  end

  def on_edit_success(payload) # rubocop:disable Style/TrivialAccessors
    @user = payload
  end

  def on_edit_failure(payload)
    redirect_to root_url, flash: { alert: payload }
  end

  def on_index_success(payload) # rubocop:disable Style/TrivialAccessors
    @users = payload
  end

  def on_new_success(payload) # rubocop:disable Style/TrivialAccessors
    @user = payload
  end

  def on_new_failure(payload)
    redirect_to root_path, flash: { alert: payload }
  end

  def on_show_success(payload) # rubocop:disable Style/TrivialAccessors
    @user = payload
  end

  def on_show_failure(payload)
    redirect_to users_path, flash: { alert: payload }
  end

  def on_update_success(payload)
    @user = payload
    slug = @user.slug
    message = 'You successfully updated your profile'
    redirect_to user_path(slug), flash: { success: message }
  end

  def on_update_failure(payload)
    redirect_to root_path, flash: { alert: payload }
  end
end # class UsersController
