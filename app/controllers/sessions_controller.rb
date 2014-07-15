
# SessionsController: actions related to Sessions (logging in and out)
class SessionsController < ApplicationController
  def create
    user = UserData.find_by_name params[:name]
    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_to root_url, flash: { success: 'Logged in!' }
    else
      alert_message = 'Invalid user name or password'
      redirect_to new_session_url, flash: { alert: alert_message }
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_url, flash: { success: 'Logged out!' }
  end
end
