
module Actions
  # Wisper-based command object called by Users controller #show action.
  class ShowUser
    include Wisper::Publisher
    attr_reader :target_slug

    def initialize(target_slug)
      @target_slug = target_slug
    end

    def execute
      result = user_repo.find_by_slug target_slug
      return broadcast_failure unless result.success?
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
      errors = { user: "Cannot find user with slug #{target_slug}!" }
      ErrorFactory.create errors
    end

    # dependencies; candidates for future injection

    def failure_result
      StoreResult.new success: false, entity: nil, errors: build_errors
    end

    def user_repo
      UserRepository.new
    end
  end # class Actions::ShowUser
end # module Actions
