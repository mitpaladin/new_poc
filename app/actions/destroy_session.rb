
module Actions
  # Wisper-based command object called by session controller #create action.
  class DestroySession
    include Wisper::Publisher

    def initialize
    end

    # No-op for now. We *could* verify that the current user isn't the Guest
    # User, but YAGNI until we do (and until we pass the current user identifier
    # into the #initialize method).
    def execute
      result = StoreResult.new success: true, errors: [], entity: nil
      broadcast_success result
    end

    private

    def broadcast_success(payload)
      broadcast :success, payload
    end
  end # class Actions::DestroySession
end # module Actions
