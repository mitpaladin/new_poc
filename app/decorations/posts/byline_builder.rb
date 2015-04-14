
require 'timestamp_builder'

require_relative 'byline_builder/attributes'

# POROs that act as presentational support for entities.
module Decorations
  # Decorations for `Post` entities. D'oh!
  module Posts
    # Builds an HTML fragment (a paragraph) containing a timestamp and author-
    # name attribution.
    class BylineBuilder
      extend Forwardable
      include TimestampBuilder

      def build(post)
        @attributes = Attributes.new(post)
        build_element.to_html
      end

      private

      def_delegators :@attributes, :author_name, :pubdate, :updated_at

      def build_element
        doc = Nokogiri::HTML::Document.new
        para = Nokogiri::XML::Element.new 'p', doc
        para << inner(doc)
        doc << para
        para
      end

      def draft?
        pubdate.nil?
      end

      def inner(doc)
        Nokogiri::XML::Element.new('time', doc).tap do |ret|
          ret[:pubdate] = 'pubdate'
          ret << innermost
        end
      end

      def innermost
        (innermost_parts + ['by', author_name]).join ' '
      end

      def innermost_parts
        if draft?
          ['Drafted', timestamp_for(updated_at.localtime)]
        else
          ['Posted', timestamp_for(pubdate)]
        end
      end
    end # class Decorations::Posts::BylineBuilder
  end
end
