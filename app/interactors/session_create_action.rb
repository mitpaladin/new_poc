
# Module DSO2 contains our second-generation Domain Service Objects, aka
#   "interactors".
module DSO2
  # Authenticate user (name) and password combination and report results.
  class SessionCreateAction < ActiveInteraction::Base
    hash :params do
      string :user, strip: true
      string :password, strip: true
    end

    def execute
      auth_params = [params[:user].to_s.parameterize, params[:password]]
      repo = UserRepository.new
      ret = repo.authenticate(*auth_params)
      unless ret.success?
        ret = StoreResult.new success: false, errors: ret.errors,
                              entity: repo.guest_user.entity
      end
      ret
    end
  end # class SessionCreateAction
end # module DSO2
