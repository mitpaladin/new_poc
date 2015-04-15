
require_relative 'parts_base'

# POROs that act as presentational support for entities.
module Decorations
  # Decorations for `Post` entities. D'oh!
  module Posts
    # Builds an HTML fragment (a paragraph) containing a timestamp and author-
    # name attribution.
    class BylineBuilder
      # Builds presentational markup for a byline with specified attributes.
      class MarkupBuilder
        # Generates content for published-post byline based on post attributes.
        class PublishedParts < PartsBase
          def status
            'Posted'
          end

          def what_time
            attributes.pubdate
          end
        end # class ...::Posts::BylineBuilder::MarkupBuilder::PublishedParts
      end # class Decorations::Posts::BylineBuilder::MarkupBuilder
    end # class Decorations::Posts::BylineBuilder
  end
end
