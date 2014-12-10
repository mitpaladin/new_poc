
module Actions
  # Wisper-based command object called by Posts controller #edit action.
  class EditPost
    include Wisper::Publisher

    def initialize(slug, current_user)
      @current_user = current_user
      @slug = slug
      @entity = dummy_entity
    end

    def execute
      prohibit_guest_access
      validate_slug
      verify_user_is_author
      broadcast_success entity
    rescue RuntimeError => the_error
      broadcast_failure the_error.message
    end

    private

    attr_reader :current_user, :slug
    attr_accessor :entity

    def broadcast_failure(payload)
      broadcast :failure, payload
    end

    def broadcast_success(payload)
      broadcast :success, payload
    end

    def prohibit_guest_access
      guest_user = user_repo.guest_user.entity
      return unless guest_user.name == current_user.name
      fail guest_user_not_authorised_message
    end

    def validate_slug
      result = post_repo.find_by_slug slug
      @entity = result.entity
      return if result.success?
      fail error_message_for_slug
    end

    def verify_user_is_author
      return if current_user.name == entity.author_name
      fail error_message_for_non_author
    end

    def dummy_entity
      Naught.build do |config|
        config.impersonate PostEntity
        config.predicates_return false
        # def author_name
        #   'Guest User'
        # end
      end.new
    end

    def post_repo
      @post_repo ||= PostRepository.new
    end

    def user_repo
      @user_repo ||= UserRepository.new
    end

    def error_message_for_non_author
      "User #{current_user.name} is not the author of this post!"
    end

    def error_message_for_slug
      "Cannot find post identified by slug: '#{slug}'!"
    end

    def guest_user_not_authorised_message
      'Not logged in as a registered user!'
    end
  end # class Actions::EditPost
end # module Actions
