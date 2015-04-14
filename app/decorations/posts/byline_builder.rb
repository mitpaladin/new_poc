
require 'timestamp_builder'

# POROs that act as presentational support for entities.
module Decorations
  # Decorations for `Post` entities. D'oh!
  module Posts
    # Builds an HTML fragment (a paragraph) containing a timestamp and author-
    # name attribution.
    class BylineBuilder
      include TimestampBuilder

      def build(post)
        init_attributes post
        build_element.to_html
      end

      private

      attr_reader :author_name, :pubdate

      def attributes_for(post)
        if post.respond_to? :to_hash
          post.to_hash.symbolize_keys
        elsif post.respond_to? :attributes
          post.attributes.to_hash.symbolize_keys
        else
          message = 'Post must expose its attributes either through an' \
            ' #attributes or #to_hash method'
          fail message
        end
      end

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

      def enforce_author_name
        message = 'post must have an :author_name attribute value'
        fail message unless @author_name
      end

      def init_attributes(post)
        attributes = attributes_for post
        @pubdate = attributes[:pubdate]
        @author_name = attributes[:author_name]
        enforce_author_name
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
        # if draft?
        #   ['Drafted', data_str(entry.updated_at)]
        # else
        #   ['Posted', pubdate_str]
        # end
        ['Posted', pubdate_str]
      end

      def data_str(data)
        timestamp_for data.localtime
        # data.localtime.strftime '%a %b %e %Y at %R %Z (%z)'
      end

      def pubdate_str
        return 'DRAFT' if draft?
        timestamp_for pubdate
      end
    end # class Decorations::Posts::BylineBuilder
  end
end
