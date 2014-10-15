
# module DSO2
class SessionNewAction < ActiveInteraction::Base
  hash :params do
    string :user, strip: true
    string :password, strip: true
  end

  def execute
    auth_params = [params[:user].to_s.parameterize, params[:password]]
    UserRepository.new.authenticate(*auth_params)
  end
end # class SessionNewAction
# end # module DSO2
