
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

  def show
    @user = UserData.friendly.find params[:id]
    authorize @user
  end
end # class UsersController
