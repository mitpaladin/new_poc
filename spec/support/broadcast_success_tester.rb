
module Actions
  # FIXME: Namespace?
  # Why the @internals? So Rubocop doesn't kvetch about how `#success`
  # "ought to be" `#success=`. Pfffft.
  class BroadcastSuccessTester
    def initialize
      @internals = { success: nil, failure: nil }
    end

    def successful?
      @internals[:success].present?
    end

    def failure?
      @internals[:failure].present?
    end

    def success(*payload)
      @internals[:success] = payload
    end

    def failure(*payload)
      @internals[:failure] = payload
    end

    def payload_for(which)
      if which == :success
        @internals[:success]
      else
        @internals[:failure]
      end
    end
  end # class BroadcastSuccessTester
end # module Actions
