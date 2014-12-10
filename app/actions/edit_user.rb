
module Actions
  # Wisper-based command object called by Users controller #edit action.
  class EditUser
    include Wisper::Publisher

    def initialize(slug, current_user)
      @current_user = current_user
      @slug = slug
      @entity = dummy_entity
    end

    def execute
      find_user_for_slug
      verify_current_user
      broadcast_success @entity
    rescue RuntimeError => error
      broadcast_failure error.message
    end

    private

    attr_reader :current_user, :entity, :slug

    def broadcast_failure(payload)
      broadcast :failure, payload
    end

    def broadcast_success(payload)
      broadcast :success, payload
    end

    # Support methods

    # ... for #initialize

    def dummy_entity
      Naught.build do |config|
        config.impersonate UserEntity
        config.predicates_return false
        # def name
        #   'No Such User'
        # end
      end.new
    end

    # ... for #execute

    def find_user_for_slug
      result = user_repo.find_by_slug slug
      @entity = result.entity || @entity
      fail "User with slug '#{slug}'' not found!" unless result.success?
    end

    def verify_current_user
      message = "Not logged in as #{entity.name}!"
      fail message unless current_user.name == entity.name
    end

    def user_repo
      @user_repo ||= UserRepository.new
    end
  end # class Actions::EditUser
end # module Actions
