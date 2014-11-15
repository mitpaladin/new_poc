
module Actions
  # Wisper-based command object called by Users controller #index action.
  class IndexUsers
    include Wisper::Publisher

    def initialize
    end

    def execute
      # UserRepository#all (currently) filters out the Guest User, which is
      # exactly what we want here
      users = UserRepository.new.all
      result = StoreResult.new success: true, errors: [], entity: users
      broadcast_success result
    end

    private

    def broadcast_success(payload)
      broadcast :success, payload
    end
  end # class Actions::IndexUsers
end # module Actions
