
module Actions
  # Wisper-based command object to be called by session controller #new action.
  class NewSession
    include Wisper::Publisher
    attr_reader :current_user

    def initialize(current_user)
      @current_user = current_user
    end

    def execute
      if already_logged_in?
        broadcast_failure
      else
        broadcast_success
      end
    end

    private

    def broadcast_success
      result = StoreResult.new success: true, errors: [], entity: guest_user
      broadcast :success, result
    end

    def broadcast_failure
      result = StoreResult.new success: false,
                               entity: nil,
                               errors: build_errors
      broadcast :failure, result
    end

    def build_errors
      errors = errors_object
      errors.add :session, "Already logged in as #{current_user.name}!"
      ErrorFactory.create errors
    end

    # Implementation helpers

    def already_logged_in?
      guest_user.name != current_user.name
    end

    def guest_user
      user_repo.guest_user.entity
    end

    # dependencies; candidates for future injection

    def errors_object
      ActiveModel::Errors.new current_user
    end

    def user_repo
      UserRepository.new
    end
  end # class Actions::NewSession
end # module Actions
