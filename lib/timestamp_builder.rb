
require 'contracts'

# Simple and to the point.
module TimestampBuilder
  include Contracts

  # FIXME: Where is the Time coming from? Why does TWZ pass locally but not CI?
  TF_CONTRACT_INPUT = Maybe[Or[ActiveSupport::TimeWithZone, Time]]

  # Provides uniform formatting for timestamps.
  Contract TF_CONTRACT_INPUT => String
  def timestamp_for(the_time = Time.zone.now)
    the_time.strftime timestamp_format
  end

  Contract None => String
  def timestamp_format
    '%a %b %e %Y at %R %Z (%z)'
  end
end # module TimestampBuilder
