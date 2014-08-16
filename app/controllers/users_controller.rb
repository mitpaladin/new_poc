
require 'permissive_user_creator'
require 'user_updater'

# UsersController: actions related to Users within our "fancy" blog.
class UsersController < ApplicationController
  after_action :verify_authorized,  except: :index
  after_action :verify_policy_scoped, only: :index

  def index
    users = UserData.registered
    @users = policy_scope users
    authorize @users
    @users = UserDataDecorator.decorate_collection(@users)
  end

  def new
    @user = UserData.new
    authorize @user
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

  private

  def update_and_redirect_with(attribs)
    @user.update_attributes attribs
    message = 'You successfully updated your profile'
    redirect_to user_path(@user.slug), flash: { success: message }
  end
end # class UsersController
