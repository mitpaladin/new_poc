
module Actions
  # Wisper-based command object called by Posts controller #edit action.
  class EditPost
    include Wisper::Publisher
    attr_reader :current_user, :slug

    def initialize(slug, current_user)
      @current_user = current_user
      @slug = slug
    end

    def execute
      return broadcast_guest_not_authorised if current_user_is_guest?
      result = post_repo.find_by_slug slug
      return broadcast_slug_failure(result) unless result.success?
      return broadcast_user_not_author unless current_user_is_author?(result)
      broadcast_success result
    end

    private

    def broadcast_failure(payload)
      broadcast :failure, payload
    end

    def broadcast_success(payload)
      broadcast :success, payload
    end

    def broadcast_guest_not_authorised
      errors = errors_object
      errors.add :user, 'Not logged in as a registered user!'
      result = StoreResult.new entity: nil, success: false,
                               errors: ErrorFactory.create(errors)
      broadcast_failure result
    end

    def broadcast_slug_failure(result)
      errors = errors_object
      message = "No post with a slug of '#{result.entity.slug}' found!"
      errors.add :slug, message
      result = StoreResult.new entity: nil, success: false,
                               errors: ErrorFactory.create(errors)
      broadcast_failure result
    end

    def broadcast_user_not_author
      errors = errors_object
      message = "User #{current_user.name} is not the author of this post!"
      errors.add :post, message
      result = StoreResult.new entity: nil, success: false,
                               errors: ErrorFactory.create(errors)
      broadcast_failure result
    end

    def current_user_is_author?(result)
      result.entity.author_name == current_user.name
    end

    def current_user_is_guest?
      guest_user = user_repo.guest_user.entity
      current_user.name == guest_user.name
    end

    # dependencies; candidates for future injection

    def errors_object
      ActiveModel::Errors.new current_user
    end

    def post_repo
      @post_repo ||= PostRepository.new
    end

    def user_repo
      @user_repo ||= UserRepository.new
    end

    def valid_result?(result)
      result.success? && current_user.name == result.entity.author_name
    end
  end # class Actions::EditPost
end # module Actions
