
module Actions
  # Wisper-based command object called by Users controller #edit action.
  class EditUser
    include Wisper::Publisher
    attr_reader :current_user, :slug

    def initialize(slug, current_user)
      @current_user = current_user
      @slug = slug
    end

    def execute
      result = user_repo.find_by_slug slug
      return broadcast_failure unless valid_result?(result)
      broadcast_success result
    end

    private

    attr_reader :user

    def broadcast_failure
      broadcast :failure, failure_result
    end

    def broadcast_success(payload)
      broadcast :success, payload
    end

    def build_errors
      errors = errors_object
      errors.add :user, "Not logged in as #{slug}!"
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
      @user_repo ||= UserRepository.new
    end

    def valid_result?(result)
      result.success? && current_user.name == result.entity.name
    end
  end # class Actions::EditUser
end # module Actions
