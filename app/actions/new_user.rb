
module Actions
  # Wisper-based command object called by Users controller #new action.
  class NewUser
    include Wisper::Publisher
    attr_reader :current_user

    def initialize(current_user)
      @current_user = current_user
    end

    def execute
      require_guest_user
      broadcast_success Newpoc::Entity::User.new({})
    rescue RuntimeError => the_error
      broadcast_failure the_error.message
    end

    private

    def broadcast_failure(payload)
      broadcast :failure, payload
    end

    def broadcast_success(payload)
      broadcast :success, payload
    end

    def require_guest_user
      guest_user = user_repo.guest_user.entity
      return if current_user.name == guest_user.name
      fail already_logged_in_message
    end

    # Support methods

    # ... for #require_guest_user

    def already_logged_in_message
      "Already logged in as #{current_user.name}!"
    end

    def user_repo
      @user_repo ||= UserRepository.new
    end
  end # class Actions::NewUser
end # module Actions
