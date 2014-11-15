
module Actions
  # Wisper-based command object called by Users controller #update action.
  class UpdateUser
    include Wisper::Publisher

    def initialize(user_data, current_user)
      @user_data = filter_user_data(user_data)
      @current_user = current_user
    end

    # FIXME: Validation rules for user_data[:email]?
    def execute
      return broadcast_failure(guest_user_prohibited) unless logged_in?
      result = save_updated_entity
      return broadcast_failure(result) unless result.success?
      broadcast_success result
    end

    private

    attr_reader :user_data, :current_user

    def broadcast_failure(payload)
      broadcast :failure, payload
    end

    def broadcast_success(payload)
      broadcast :success, payload
    end

    def filter_user_data(user_data)
      data = user_data.symbolize_keys.select do |attrib, _value|
        permitted_attribs.include? attrib
      end
      FancyOpenStruct.new data
    end

    def guest_user
      user_repo.guest_user.entity
    end

    def guest_user_prohibited
      errors = { user: 'Not logged in as a registered user!' }
      StoreResult.new success: false, entity: nil,
                      errors: ErrorFactory.create(errors)
    end

    def logged_in?
      current_user.name != guest_user.name
    end

    def permitted_attribs
      [:email, :profile]
    end

    def save_updated_entity
      entity = updated_entity
      user_repo.update entity
    end

    def updated_entity
      attributes = current_user.attributes
      user_data.each_key do |attrib|
        attributes[attrib] = user_data[attrib]
      end
      current_user.class.new attributes
    end

    def user_repo
      @user_repo ||= UserRepository.new
    end
  end # class Actions::UpdateUser
end # module Actions
