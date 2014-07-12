
# SessionsController: actions related to Sessions (logging in and out)
class SessionsController < ApplicationController
  def create
    user = UserData.find_by_name params[:name]
    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_to root_url, flash: { success: 'Logged in!' }
    else
      flash.now.alert 'Invalid user name or password!'
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_url, flash: { success: 'Logged out!' }
  end
end
