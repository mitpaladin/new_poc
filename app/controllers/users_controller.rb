
require 'permissive_user_creator'

require 'create_user'
require 'edit_user'
require 'index_users'
require 'new_user'
require 'show_user'
require 'update_user'

# UsersController: actions related to Users within our "fancy" blog.
class UsersController < ApplicationController
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
    @user = payload.entity
    redirect_to root_url, flash: { success: 'Thank you for signing up!' }
  end

  def on_create_failure(payload)
    @user = payload.entity
    @errors = payload.errors
    render 'new'
  end

  def on_edit_success(payload)
    @user = payload.entity
  end

  def on_edit_failure(payload)
    @errors = payload.errors
    redirect_to root_url, flash: { alert: payload.errors.first[:message] }
  end

  def on_index_success(payload)
    @users = payload.entity
  end

  def on_new_success(payload)
    @user = payload.entity
  end

  def on_new_failure(payload)
    @user = nil
    redirect_to root_path, flash: { alert: payload.errors.first[:message] }
  end

  def on_show_success(payload)
    @user = payload.entity
  end

  def on_show_failure(payload)
    redirect_to users_path, flash: { alert: payload.errors.first[:message] }
  end

  # FIXME! FIXME! FIXME! Where's the DAO abstraction? FIXME! FIXME! FIXME!
  def on_update_success(payload)
    dao = UserRepository.new.instance_variable_get(:@dao)
    @user = dao.find_by_slug payload.entity.slug
    message = 'You successfully updated your profile'
    redirect_to user_path(@user.slug), flash: { success: message }
  end

  def on_update_failure(payload)
    redirect_to root_path, flash: { alert: payload.errors.first[:message] }
  end
end # class UsersController
