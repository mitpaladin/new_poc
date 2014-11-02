
require 'permissive_user_creator'
require 'user_updater'

require 'create_user'
require 'index_users'
require 'new_user'

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
    @user = UserData.friendly.find(params[:id]).decorate
    authorize @user
  end

  # FIXME: Needs a DSO. When calling #update_attributes, raises an error.
  # The error is ActiveModel::ForbiddenAttributesError.
  def update
    @user = UserData.find params[:id]
    authorize @user
    entity = CCO::UserCCO.to_entity @user
    result = DSO::UserUpdater.run user: entity, user_data: params[:user_data]
    if result.valid?
      update_and_redirect_with result.result
    else
      render 'edit'
    end
  end

  # Action responders must be public to receive Wisper notifications; see
  # https://github.com/krisleech/wisper/issues/75 for relevant detail.

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

  private

  def update_and_redirect_with(attribs)
    @user.update_attributes attribs
    message = 'You successfully updated your profile'
    redirect_to user_path(@user.slug), flash: { success: message }
  end
end # class UsersController
