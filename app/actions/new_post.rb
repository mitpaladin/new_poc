
module Actions
  # Wisper-based command object called by Posts controller #new action.
  class NewPost
    include Wisper::Publisher
    attr_reader :current_user

    def initialize(current_user)
      @current_user = current_user
    end

    def execute
      guest_user = user_repo.guest_user.entity
      return broadcast_auth_failure if current_user.name == guest_user.name
      entity = PostEntity.new author_name: current_user.name
      result = StoreResult.new success: true, entity: entity,
                               errors: ErrorFactory.create([])
      broadcast_success result
    end

    private

    def broadcast_failure(payload)
      broadcast :failure, payload
    end

    def broadcast_success(payload)
      broadcast :success, payload
    end

    def broadcast_auth_failure
      broadcast_failure_for :user, 'Not logged in as a registered user!'
    end

    def broadcast_failure_for(key, message)
      result = StoreResult.new success: false, entity: nil,
                               errors: build_errors_for(key, message)
      broadcast_failure result
    end

    def build_errors_for(key, message)
      [{ field: key.to_s, message: message }]
    end

    def user_repo
      @user_repo ||= UserRepository.new
    end
  end # class Actions::NewPost
end # module Actions
