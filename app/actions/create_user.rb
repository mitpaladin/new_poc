
module Actions
  # Wisper-based command object called by Users controller #new action.
  class CreateUser
    include Wisper::Publisher

    def initialize(current_user, user_data)
      @current_user = current_user
      @user_data = user_data.to_h.symbolize_keys
      @user_slug = user_data[:slug] || user_data[:name].parameterize
      @user_data.delete :slug # will be recreated on successful save
      @errors = []
    end

    def execute
      require_guest_user
      verify_entity_does_not_exist
      add_user_entity_to_repo
      broadcast_success entity
    rescue RuntimeError => the_error
      broadcast_failure the_error.message
    end

    private

    attr_reader :current_user, :user_data, :entity

    def broadcast_failure(payload)
      broadcast :failure, payload
    end

    def broadcast_success(payload)
      broadcast :success, payload
    end

    def add_user_entity_to_repo
      result = user_repo.add UserEntity.new(user_data)
      @entity = result.entity
      return if result.success?
      fail user_data.to_json
    end

    def require_guest_user
      guest_user = user_repo.guest_user.entity
      return if current_user.name == guest_user.name
      fail already_logged_in_message
    end

    def verify_entity_does_not_exist
      result = user_repo.find_by_slug @user_slug
      return unless result.success?
      fail entity_already_exists_message
    end

    # Support methods

    # ... for #require_guest_user

    def already_logged_in_message
      "Already logged in as #{current_user.name}!".to_json
    end

    def user_repo
      @user_repo ||= UserRepository.new
    end

    # ... for #verify_entity_does_not_exist

    def entity_already_exists_message
      "A record identified by slug '#{@user_slug}' already exists!".to_json
    end
  end # class Actions::CreateUser
end # module Actions
