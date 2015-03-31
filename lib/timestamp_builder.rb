
# Simple and to the point.
module TimestampBuilder
  # Provides uniform formatting for timestamps.
  # Uses ActiveSupport::TimeWithZone.
  def timestamp_for(the_time = Time.now)
    Time.zone.at(the_time.to_time).strftime _timestamp_format
  end

  def _timestamp_format
    '%a %b %e %Y at %R %Z (%z)'
  end
end # module TimestampBuilder
