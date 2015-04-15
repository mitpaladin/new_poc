
require_relative 'markup_builder/published_parts'
require_relative 'markup_builder/draft_parts'

# POROs that act as presentational support for entities.
module Decorations
  # Decorations for `Post` entities. D'oh!
  module Posts
    # Builds an HTML fragment (a paragraph) containing a timestamp and author-
    # name attribution.
    class BylineBuilder
      # Builds presentational markup for a byline with specified attributes.
      class MarkupBuilder
        extend Forwardable

        def initialize(attributes)
          @attributes = attributes
          @content_class = pubdate ? PublishedParts : DraftParts
        end

        def to_html
          para = element 'p'
          para << inner
          doc << para
          para.to_html
        end

        private

        def_delegators :@attributes, :author_name, :pubdate, :updated_at

        def doc
          @doc ||= Nokogiri::HTML::Document.new
        end

        def draft?
          pubdate.nil?
        end

        def element(tag)
          Nokogiri::XML::Element.new(tag, doc)
        end

        def inner
          element('time').tap do |time_tag|
            time_tag[:pubdate] = 'pubdate'
            time_tag << @content_class.new(@attributes).content
          end
        end
      end # class Decorations::Posts::BylineBuilder::MarkupBuilder
      private_constant :MarkupBuilder
    end # class Decorations::Posts::BylineBuilder
  end
end
