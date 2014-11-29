
module Actions
  # Wisper-based command object called by Posts controller #new action.
  class NewPost
    include Wisper::Publisher

    def initialize(current_user)
      @current_user = current_user
    end

    def execute
      guest_user = user_repo.guest_user.entity
      return broadcast_auth_failure if current_user.name == guest_user.name
      build_and_broadcast_entity
    end

    private

    attr_reader :current_user

    def broadcast_failure(invalid_entity)
      broadcast :failure, invalid_entity
    end

    def broadcast_success(payload)
      broadcast :success, payload
    end

    def broadcast_auth_failure
      message = 'must be that of a logged-in, registered user'
      entity = PostEntity.new({})
      entity.errors.add :author_name, message
      broadcast_failure entity
    end

    def build_and_broadcast_entity
      entity = PostEntity.new author_name: current_user.name
      broadcast_success entity
    end

    def user_repo
      @user_repo ||= UserRepository.new
    end
  end # class Actions::NewPost
end # module Actions
