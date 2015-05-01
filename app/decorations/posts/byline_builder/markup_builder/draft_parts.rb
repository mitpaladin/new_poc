
# POROs that act as presentational support for entities.
module Decorations
  # Decorations for `Post` entities. D'oh!
  module Posts
    # Builds an HTML fragment (a paragraph) containing a timestamp and author-
    # name attribution.
    class BylineBuilder
      # Builds presentational markup for a byline with specified attributes.
      class MarkupBuilder
        # Content differentiating listing of a draft post from that of a public
        # post.
        module DraftParts
          def status
            'Drafted'
          end

          def what_time
            attributes.updated_at
          end
        end
      end # class Decorations::Posts::BylineBuilder::MarkupBuilder
    end # class Decorations::Posts::BylineBuilder
  end
end
