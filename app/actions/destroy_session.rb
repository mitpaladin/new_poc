
module Actions
  # Wisper-based command object called by session controller #create action.
  class DestroySession
    include Wisper::Publisher

    # No-op for now. We *could* verify that the current user isn't the Guest
    # User, but YAGNI until we do (and until we pass the current user identifier
    # into the #initialize method).
    def execute
      broadcast_success :success
    end

    private

    def broadcast_success(payload)
      broadcast :success, payload
    end
  end # class Actions::DestroySession
end # module Actions
