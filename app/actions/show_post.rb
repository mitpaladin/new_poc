
module Actions
  # Wisper-based command object called by Posts controller #show action.
  class ShowPost
    include Wisper::Publisher

    def initialize(target_slug, current_user)
      @target_slug = target_slug
      @current_user = current_user
      @entity = build_dummy_entity
    end

    def execute
      validate_slug
      verify_authorisation
      broadcast_success @entity
    rescue RuntimeError => the_error
      broadcast_failure the_error.message
    end

    private

    attr_accessor :entity
    attr_reader :current_user, :target_slug

    def broadcast_failure(message)
      broadcast :failure, message
    end

    def broadcast_success(payload)
      broadcast :success, payload
    end

    def build_dummy_entity
      Naught.build do |config|
        config.impersonate Newpoc::Entity::Post
        config.predicates_return false
      end.new
    end

    def validate_slug
      result = post_repo.find_by_slug target_slug
      @entity = result.entity
      return if result.success?
      fail error_message_for_slug
    end

    def post_repo
      @post_repo ||= PostRepository.new
    end

    def verify_authorisation
      return if entity.published? || current_user.name == entity.author_name
      fail error_message_for_slug
    end

    def error_message_for_slug
      "Cannot find post identified by slug: '#{target_slug}'!"
    end
  end # class Actions::ShowPost
end # module Actions
