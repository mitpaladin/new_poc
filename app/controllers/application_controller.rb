
# Main application controller. Hang things off here that are needed by multiple
# controllers (which all subclass this one).
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
end
