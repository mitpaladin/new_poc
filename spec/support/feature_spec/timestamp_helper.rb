
require 'timestamp_builder'

# Feature-spec support class for decorator-style timestamp strings.
class FeatureSpecTimestampHelper
  extend TimestampBuilder

  def self.to_timestamp_s(the_time = Time.zone.now)
    timestamp_for the_time
  end
end
