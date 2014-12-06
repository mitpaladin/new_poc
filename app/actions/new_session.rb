
module Actions
  # Wisper-based command object to be called by session controller #new action.
  class NewSession
    include Wisper::Publisher
    attr_reader :current_user

    def initialize(current_user)
      @current_user = current_user
    end

    def execute
      verify_not_logged_in
      broadcast_success guest_user
    rescue RuntimeError => error
      broadcast_failure error.message
    end

    private

    def broadcast_success(payload)
      broadcast :success, payload
    end

    def broadcast_failure(message)
      broadcast :failure, message
    end

    def verify_not_logged_in
      return if guest_user.name == current_user.name
      fail "Already logged in as #{current_user.name}!"
    end

    def guest_user
      @guest_user ||= user_repo.guest_user.entity
    end

    # dependencies; candidates for future injection

    def user_repo
      @user_repo ||= UserRepository.new
    end
  end # class Actions::NewSession
end # module Actions
