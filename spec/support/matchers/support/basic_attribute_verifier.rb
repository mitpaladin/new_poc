
module MatcherSupport
  # Class that compares basic attributes of two blog objects, and builds list of
  # messages describing any differences. Called directly by matcher.
  class BasicAttributeVerifier
    attr_reader :messages

    def initialize(actual_blog, other_blog)
      @actual_blog = actual_blog
      @other_blog = other_blog
      @messages = [nil]
    end

    def valid?
      messages.empty?
    end

    def run
      @messages = []
      items = Internal::ComparedItemsBuilder.new(actual_blog, other_blog).build
      items.each { |item| @messages << compare(item) }
      @messages.delete_if { |x| !x }
      self
    end

    protected

    attr_reader :actual_blog, :other_blog

    private

    def build_failure_message_for(item)
      format_str = 'Expected %s was "%s", but actual %s was "%s"'
      other = item.accessor.call(item.other).ai plain: true
      actual = item.accessor.call(item.actual).ai plain: true
      format format_str, item.name, other, item.name, actual
    end

    def compare(item)
      actual = item.accessor.call item.actual
      other = item.accessor.call item.other
      build_failure_message_for item unless item.comparator.call actual, other
    end
  end
end # module MatcherSupport
