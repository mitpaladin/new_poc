
module Actions
  # Wisper-based command object called by Users controller #update action.
  class UpdateUser
    include Wisper::Publisher

    def initialize(user_data, current_user)
      @user_data = filter_user_data(user_data)
      @current_user = current_user
    end

    def execute
      prohibit_guest_access
      update_entity
      broadcast_success @entity
    rescue RuntimeError => error
      broadcast_failure error.message
    end

    private

    attr_reader :user_data, :current_user

    # Support methods

    # ... for #initialize

    def filter_user_data(user_data)
      data = user_data.symbolize_keys.select do |attrib, _value|
        permitted_attribs.include? attrib
      end
      FancyOpenStruct.new data
    end

    # ... for #execute

    def broadcast_failure(payload)
      broadcast :failure, payload
    end

    def broadcast_success(payload)
      broadcast :success, payload
    end

    def prohibit_guest_access
      return unless guest_user.name == current_user.name
      fail guest_user_not_authorised_message
    end

    def update_entity
      result = user_repo.update current_user.slug, user_data
      @entity = result.entity
      return if result.success?
      fail @entity.to_json
    end

    def guest_user
      user_repo.guest_user.entity
    end

    def guest_user_not_authorised_message
      'Not logged in as a registered user!'
    end

    def user_repo
      @user_repo ||= UserRepository.new
    end

    def permitted_attribs
      [:email, :profile]
    end
  end # class Actions::UpdateUser
end # module Actions
