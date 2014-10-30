
require 'permissive_user_creator'
require 'user_updater'

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
    result = DSO::PermissiveUserCreator.run user_data: params[:user_data]
    @user = result.result
    authorize @user
    if result.valid? && @user.save
      redirect_to root_url, flash: { success: 'Thank you for signing up!' }
    else
      render 'new'
    end
  end

  def edit
    @user = UserData.find params[:id]
    authorize @user
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
