
module Actions
  # Wisper-based command object called by Posts controller #new action.
  class NewPost
    include Wisper::Publisher

    def initialize(current_user)
      @current_user = current_user
    end

    def execute
      prohibit_guest_access
      broadcast_success(build_entity)
    rescue RuntimeError => the_error
      broadcast_failure the_error.message
    end

    private

    attr_reader :current_user

    def broadcast_failure(invalid_entity)
      broadcast :failure, invalid_entity
    end

    def broadcast_success(payload)
      broadcast :success, payload
    end

    def build_entity
      Newpoc::Entity::Post.new author_name: current_user.name
    end

    def prohibit_guest_access
      guest_user = user_repo.guest_user.entity
      return unless guest_user.name == current_user.name
      fail guest_user_not_authorised_message
    end

    def guest_user_not_authorised_message
      'Not logged in as a registered user!'
    end

    def user_repo
      @user_repo ||= UserRepository.new
    end
  end # class Actions::NewPost
end # module Actions
