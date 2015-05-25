
require 'contracts'

# POROs that act as presentational support for entities.
module Decorations
  # Decorations for `Post` entities. D'oh!
  module Posts
    # Builds an HTML fragment (a paragraph) containing a timestamp and author-
    # name attribution.
    class BylineBuilder
      # Builds presentational markup for a byline with specified attributes.
      class MarkupBuilder
        # Uses Ox rather than, e.g., Nokogiri to produce/represent markup.
        class OxBuilder
          include Contracts

          Contract Proc => OxBuilder
          def build(&block)
            doc << instance_eval(&block)
            self
          end

          Contract None => String
          def dump
            Ox.dump doc
          end

          private

          Contract None => Ox::Document
          def doc
            @doc ||= new_doc
          end

          Contract String => Ox::Element
          def element(name)
            Ox::Element.new name
          end

          def new_doc
            Ox::Document.new
          end
        end # class Decorations::Posts::BylineBuilder::MarkupBuilder::OxBuilder
      end # class Decorations::Posts::BylineBuilder::MarkupBuilder
    end # class Decorations::Posts::BylineBuilder
  end
end
