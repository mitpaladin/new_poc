
# Verifies equality of two entities, which may include timestamps (eg, :pubdate)
class TimestampedEntityVerifier
  module Internals
    # Filters attributes of an entity, separating timestamps from others.
    class AttributeFilter
      attr_reader :attributes, :filtered_attributes, :timestamps

      def initialize(attributes, excluded = default_excluded)
        @attributes = attributes
        @excluded = excluded
      end

      def add_exclusion(attribute)
        @excluded.push attribute
        self
      end

      def filter
        @timestamps = {}
        @filtered_attributes = @attributes.reject do |attrib, value|
          @excluded.include?(attrib) || timestamp?(attrib, value)
        end
        self
      end

      private

      def default_excluded
        [:created_at, :updated_at, :password, :password_confirmation]
      end

      def timestamp?(attribute, value)
        _ = value.to_datetime
        @timestamps[attribute] = value
        true
      rescue ArgumentError
        false
      end
    end # class TimestampedEntityVerifier::Internals::AttributeFilter

    # Contains list of "reasons for failure matching attributes".
    class Reasons
      extend Forwardable
      def_delegator :@items, :empty?, :empty?

      def initialize
        @items = {}
      end

      def add_unless(attribute, expected, actual)
        return self if expected == actual
        @items[attribute] = { expected: expected, actual: actual }
        self
      end

      def to_a
        [].tap { |ret| @items.each_key { |key| ret.push format_item(key) } }
      end

      private

      def format_item(key)
        fmt = ':%s had the value "%s" but "%s" was expected'
        format fmt, key.to_s, @items[key][:actual], @items[key][:expected]
      end
    end # class TimestampedEntityVerifier::Internals::Reasons
  end # module TimestampedEntityVerifier::Internals
  private_constant :Internals
  include Internals

  def initialize(source, actual)
    @source_filter = AttributeFilter.new(source.attributes)
    @actual_filter = AttributeFilter.new(actual.attributes)
    @failures = [] # benign but bogus initial value; see #failures
  end

  def failures
    @failures.to_a
  end

  def verify
    @failures = Reasons.new
    # FIXME: Feature Envy: @source_filter and @actual_filter are *always* used
    #        together, even if not always in the same order.
    check_and_exclude @source_filter, @actual_filter
    check_timestamps @source_filter, @actual_filter
    check_attrib @actual_filter, @source_filter
    self
  end

  private

  def check_attrib(source_filter, actual_filter)
    source_filter.filter.filtered_attributes.each do |attrib, value|
      @failures.add_unless attrib, value, actual_filter.attributes[attrib]
      yield(attrib) if block_given?
    end
    self
  end

  def check_and_exclude(source_filter, actual_filter)
    check_attrib(source_filter, actual_filter) do |attrib|
      actual_filter.add_exclusion attrib
    end
    self
  end

  def check_timestamps(source_filter, actual_filter)
    source_filter.timestamps.each_key do |key|
      ref_value = source_filter.attributes[key].to_time
      other_value = actual_filter.attributes[key].to_time
      @failures.add_unless key, ref_value, other_value
    end
    self
  end
end
