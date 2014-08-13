
require 'permissive_user_creator'

# UsersController: actions related to Users within our "fancy" blog.
class UsersController < ApplicationController
  after_action :verify_authorized,  except: :index
  after_action :verify_policy_scoped, only: :index

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
    @user = UserData.friendly.find params[:id]
    authorize @user
  end

  # FIXME: Needs a DSO. When calling #update_attributes, raises an error.
  # The error is ActiveModel::ForbiddenAttributesError.
  def update
    @user = UserData.find params[:id]
    authorize @user
    update_attributes_from @user, params
    if @user.save
      message = 'You successfully updated your profile'
      redirect_to user_path(@user), flash: { success: message }
    else
      render 'edit'
    end
  end

  private

  def update_attributes_from(user, params)
    [:name, :email, :profile].each do |item|
      user[item] = params[:user_data][item]
    end
  end
end # class UsersController
