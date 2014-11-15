
module Actions
  # Wisper-based command object called by Posts controller #show action.
  class ShowPost
    include Wisper::Publisher
    attr_reader :current_user, :target_slug

    def initialize(target_slug, current_user)
      @target_slug = target_slug
      @current_user = current_user
    end

    def execute
      result = post_repo.find_by_slug target_slug
      return broadcast_failure unless result.success?
      return broadcast_failure unless current_user_is_authorised?(result)
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
      errors = { user: "Cannot find post with slug #{target_slug}!" }
      ErrorFactory.create errors
    end

    def current_user_is_authorised?(result)
      return true if result.entity.pubdate.present?
      result.entity.author_name == current_user.name
    end

    # dependencies; candidates for future injection

    def failure_result
      StoreResult.new success: false, entity: nil, errors: build_errors
    end

    def post_repo
      @post_repo ||= PostRepository.new
    end
  end # class Actions::ShowPost
end # module Actions
