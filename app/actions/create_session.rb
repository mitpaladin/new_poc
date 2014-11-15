
module Actions
  # Wisper-based command object called by session controller #create action.
  class CreateSession
    include Wisper::Publisher
    attr_reader :user_name, :password

    def initialize(user_name, password)
      @user_name = user_name
      @password = password
    end

    def execute
      auth_params = [user_name.to_s.parameterize, password]
      result = UserRepository.new.authenticate(*auth_params)
      return broadcast_success(result) if result.success?
      broadcast_failure result
    end

    private

    def broadcast_failure(result)
      broadcast :failure, payload_with_errors_for(result)
    end

    def broadcast_success(payload)
      broadcast :success, payload
    end

    def payload_with_errors_for(result)
      StoreResult.new success: false, errors: result.errors,
                      entity: UserRepository.new.guest_user.entity
    end
  end # class Actions::CreateSession
end # module Actions
