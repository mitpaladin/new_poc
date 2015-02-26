
# Encapsulates our standard Wisper-based success/failure notification sending.
module Broadcaster
  include Wisper::Publisher

  private

  def broadcast_failure(payload)
    broadcast :failure, payload
  end

  def broadcast_success(payload)
    broadcast :success, payload
  end
end # module Broadcaster
