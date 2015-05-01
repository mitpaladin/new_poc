
require 'timestamp_builder'

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
        include TimestampBuilder
        include Contracts

        attr_init :attributes do
          validate_initialisers! attributes
          extend PublishedParts if pubdate
          extend DraftParts unless pubdate
        end

        Contract None => String
        def to_html
          para = element 'p'
          para << inner
          doc << para
          para.to_html
        end

        private

        def_delegators :attributes, :author_name, :pubdate, :updated_at

        Contract None => String
        def content
          [status, timestamp_for(what_time), 'by', attributes.author_name]
            .join ' '
        end

        Contract None => Nokogiri::HTML::Document
        def doc
          @doc ||= Nokogiri::HTML::Document.new
        end

        Contract None => Bool
        def draft?
          pubdate.nil?
        end

        Contract String => Nokogiri::XML::Element
        def element(tag)
          Nokogiri::XML::Element.new(tag, doc)
        end

        Contract None => Nokogiri::XML::Element
        def inner
          element('time').tap do |time_tag|
            time_tag[:pubdate] = 'pubdate'
            time_tag << content
          end
        end

        VI_PARAMS = {
          author_name: String,
          pubdate: Maybe[ActiveSupport::TimeWithZone],
          updated_at: Maybe[ActiveSupport::TimeWithZone]
        }
        def validate_initialisers!(_attributes)
          true
        end
      end # class Decorations::Posts::BylineBuilder::MarkupBuilder
      private_constant :MarkupBuilder
    end # class Decorations::Posts::BylineBuilder
  end
end
