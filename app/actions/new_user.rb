
module Actions
  # Wisper-based command object called by Users controller #new action.
  class NewUser
    include Wisper::Publisher
    attr_reader :current_user

    def initialize(current_user)
      @current_user = current_user
    end

    def execute
      entity = UserEntity.new({})
      result = StoreResult.new success: true, errors: [], entity: entity
      broadcast_success result
    end

    private

    def broadcast_success(payload)
      broadcast :success, payload
    end
  end # class Actions::NewUser
end # module Actions
