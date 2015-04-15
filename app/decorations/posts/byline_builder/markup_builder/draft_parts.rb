
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
        # Generates content for draft-post byline based on post attributes.
        class DraftParts < PartsBase
          def status
            'Drafted'
          end

          def what_time
            attributes.updated_at.localtime
          end
        end # class Decorations::Posts::BylineBuilder::MarkupBuilder::DraftParts
      end # class Decorations::Posts::BylineBuilder::MarkupBuilder
    end # class Decorations::Posts::BylineBuilder
  end
end
