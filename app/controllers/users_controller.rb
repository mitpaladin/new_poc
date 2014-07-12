
require 'permissive_user_creator'

# UsersController: actions related to Users within our "fancy" blog.
class UsersController < ApplicationController
  def new
    @user = UserData.new
  end

  def create
    result = DSO::PermissiveUserCreator.run user_data: params[:user_data]
    @user = result.result
    if result.valid? && @user.save
      redirect_to root_url, flash: { success: 'Thank you for signing up!' }
    else
      render 'new'
    end
  end
end # class UsersController
