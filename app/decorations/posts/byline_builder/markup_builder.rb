
require 'contracts'

require_relative 'attributes'
require_relative 'markup_builder/draft_parts'
require_relative 'markup_builder/ox_builder'
require_relative 'markup_builder/published_parts'

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
        include Contracts

        Contract Attributes => MarkupBuilder
        def initialize(attributes)
          @attributes = attributes
          @content_class = pubdate ? PublishedParts : DraftParts
          self
        end

        Contract None => String
        def to_html
          reformat build.dump
        end

        private

        def_delegators :@attributes, :author_name, :pubdate, :updated_at

        Contract None => OxBuilder
        def build
          content_class = @content_class
          attributes = @attributes
          OxBuilder.new.build do
            para = element 'p'
            inner = element('time').tap do |time_tag|
              time_tag['pubdate'] = 'pubdate'
              time_tag << content_class.new(attributes).content
            end
            para << inner
          end
        end

        Contract String => String
        def reformat(as_built)
          as_built.lines.map(&:strip).join
        end
      end # class Decorations::Posts::BylineBuilder::MarkupBuilder
      # private_constant :MarkupBuilder
    end # class Decorations::Posts::BylineBuilder
  end
end
