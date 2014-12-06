
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
      authenticate_user
      broadcast_success @entity
    rescue RuntimeError => error
      broadcast_failure error.message
    end

    private

    def broadcast_failure(payload)
      broadcast :failure, payload
    end

    def broadcast_success(payload)
      broadcast :success, payload
    end

    def authenticate_user
      auth_params = [user_name.to_s.parameterize, password]
      result = UserRepository.new.authenticate(*auth_params)
      @entity = result.entity
      return if result.success?
      fail result.errors.first[:message]
    end
  end # class Actions::CreateSession
end # module Actions
