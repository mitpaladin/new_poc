
# Simple and to the point.
module TimestampBuilder
  # Provides uniform formatting for timestamps.
  def timestamp_for(the_time = Time.zone.now)
    the_time.strftime timestamp_format
  end

  def timestamp_format
    '%a %b %e %Y at %R %Z (%z)'
  end
end # module TimestampBuilder
