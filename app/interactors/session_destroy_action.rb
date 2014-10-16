
# Module DSO2 contains our second-generation Domain Service Objects, aka
#   "interactors".
module DSO2
  # Report that "current user" is Guest User instead of previously logged-in
  # user.
  class SessionDestroyAction < ActiveInteraction::Base
    def execute
      UserRepository.new.guest_user
    end
  end # class SessionNewAction
end # module DSO2
