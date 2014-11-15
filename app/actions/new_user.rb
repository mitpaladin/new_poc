
module Actions
  # Wisper-based command object called by Users controller #new action.
  class NewUser
    include Wisper::Publisher
    attr_reader :current_user

    def initialize(current_user)
      @current_user = current_user
    end

    def execute
      guest_user = user_repo.guest_user.entity
      return broadcast_failure unless current_user.name == guest_user.name
      entity = UserEntity.new({})
      result = StoreResult.new success: true, errors: [], entity: entity
      broadcast_success result
    end

    private

    def broadcast_failure
      broadcast :failure, failure_result
    end

    def broadcast_success(payload)
      broadcast :success, payload
    end

    def build_errors
      errors = errors_object
      errors.add :user, "Already logged in as #{current_user.name}!"
      ErrorFactory.create errors
    end

    # dependencies; candidates for future injection

    def errors_object
      ActiveModel::Errors.new current_user
    end

    def failure_result
      StoreResult.new success: false, entity: nil, errors: build_errors
    end

    def user_repo
      UserRepository.new
    end
  end # class Actions::NewUser
end # module Actions
