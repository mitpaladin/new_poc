
module Actions
  # Wisper-based command object called by Users controller #show action.
  class ShowUser
    include Wisper::Publisher

    def initialize(target_slug)
      @target_slug = target_slug
    end

    def execute
      validate_slug
      broadcast_success entity
    rescue RuntimeError => error
      broadcast_failure error.message
    end

    private

    attr_reader :target_slug, :entity

    def broadcast_failure(payload)
      broadcast :failure, payload
    end

    def broadcast_success(payload)
      broadcast :success, payload
    end

    # Support methods

    # ... for #execute

    def validate_slug
      result = user_repo.find_by_slug target_slug
      @entity = result.entity
      return if result.success?
      fail error_message_for_slug
    end

    def error_message_for_slug
      "Cannot find user identified by slug #{target_slug}!"
    end

    def user_repo
      @user_repo ||= UserRepository.new
    end
  end # class Actions::ShowUser
end # module Actions
