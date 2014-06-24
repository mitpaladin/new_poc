
module MatcherSupport
  module Internal
    # Class to build list of attribute-verification objects used in
    # BasicAttributeVerifier#run.
    class ComparedItemsBuilder
      attr_reader :actual_blog, :other_blog

      def initialize(actual_blog, other_blog)
        @actual_blog = actual_blog
        @other_blog = other_blog
      end

      def build
        items = []
        attribute_parts.each do |x|
          item = FancyOpenStruct.new x.merge(common_parts)
          items << item
        end
        items
      end

      private

      def attribute_parts
        items = [
          { name: 'title', accessor: ->(x) { x.title } },
          { name: 'subtitle', accessor: ->(x) { x.subtitle } },
          { name: 'entry count', accessor: ->(x) { x.entries.count } }
        ]
        items.each_with_index { |x, n| items[n] = FancyOpenStruct.new x }
      end

      def common_parts
        FancyOpenStruct.new actual:     actual_blog,
                            other:      other_blog,
                            comparator: -> (a, b) { a == b }
      end
    end
  end # module MatcherSupport::Internal
end # module MatcherSupport
