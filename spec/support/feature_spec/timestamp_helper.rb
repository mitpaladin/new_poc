
# Feature-spec support class for decorator-style timestamp strings.
class FeatureSpecTimestampHelper
  extend DecoratorShared

  def self.to_timestamp_s(the_time = Time.now)
    timestamp_for the_time
  end
end
