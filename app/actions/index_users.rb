
module Actions
  # Wisper-based command object called by Users controller #index action.
  class IndexUsers
    include Wisper::Publisher

    def execute
      # UserRepository#all (currently) filters out the Guest User, which is
      # exactly what we want here
      broadcast_success UserRepository.new.all
    end

    private

    def broadcast_success(payload)
      broadcast :success, payload
    end
  end # class Actions::IndexUsers
end # module Actions
