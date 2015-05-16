
require 'contracts'

# Simple and to the point.
module TimestampBuilder
  include Contracts

  # Provides uniform formatting for timestamps.
  Contract Maybe[ActiveSupport::TimeWithZone] => String
  def timestamp_for(the_time = Time.zone.now)
    the_time.strftime timestamp_format
  end

  Contract None => String
  def timestamp_format
    '%a %b %e %Y at %R %Z (%z)'
  end
end # module TimestampBuilder
