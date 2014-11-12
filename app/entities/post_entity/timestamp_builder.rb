
# Formerly included in a Draper decorator, when we used those pervasively.
module EntityShared
  # Provides uniform formatting for timestamps.
  def timestamp_for(the_time = Time.now)
    the_time.to_time.localtime.strftime timestamp_format
  end

  def timestamp_format
    '%a %b %e %Y at %R %Z (%z)'
  end
end # module EntityShared
