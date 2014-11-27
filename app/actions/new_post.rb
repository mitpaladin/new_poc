
require 'main_logger'

module Actions
  # Wisper-based command object called by Posts controller #new action.
  class NewPost
    include Wisper::Publisher

    def initialize(current_user, post_attributes = {}, errors = [])
      @current_user = current_user
      @post_attributes = post_attributes
      @errors = errors
    end

    def execute
      guest_user = user_repo.guest_user.entity
      return broadcast_auth_failure if current_user.name == guest_user.name
      build_and_broadcast_entity
    end

    private

    attr_reader :current_user, :errors, :post_attributes

    def broadcast_failure(payload, invalid_entity)
      # @logger ||= MainLogger.log('log/new_post.log')
      # @logger.debug [payload, invalid_entity, __FILE__, __LINE__]
      broadcast :failure, payload, invalid_entity
    end

    def broadcast_success(payload)
      broadcast :success, payload
    end

    def broadcast_auth_failure
      message = 'Not logged in as a registered user!'
      result = StoreResult.new success: false, entity: nil,
                               errors: build_errors_for(:user, message)
      broadcast_failure result, PostEntity.new({})
    end

    def build_and_broadcast_entity
      attribs = post_attributes.merge author_name: current_user.name
      entity = PostEntity.new attribs
      if errors.empty?
        result = StoreResult.new success: true, entity: entity,
                                 errors: ErrorFactory.create(errors)
        broadcast_success result
      else
        result = StoreResult.new success: false, entity: nil, errors: errors
        broadcast_failure result, entity
      end
    end

    def build_errors_for(key, message)
      [{ field: key.to_s, message: message }]
    end

    def user_repo
      @user_repo ||= UserRepository.new
    end
  end # class Actions::NewPost
end # module Actions
