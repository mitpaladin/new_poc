
require 'timestamp_builder'

require_relative 'byline_builder/attributes'
require_relative 'byline_builder/markup_builder'

# POROs that act as presentational support for entities.
module Decorations
  # Decorations for `Post` entities. D'oh!
  module Posts
    # Builds an HTML fragment (a paragraph) containing a timestamp and author-
    # name attribution.
    class BylineBuilder
      def build(post)
        MarkupBuilder.new(Attributes.new post).to_html
      end
    end # class Decorations::Posts::BylineBuilder
  end
end
