
# POROs that act as presentational support for entities.
module Decorations
  # Decorations for `Post` entities. D'oh!
  module Posts
    # Builds an HTML fragment (a paragraph) containing a timestamp and author-
    # name attribution.
    class BylineBuilder
      # Builds presentational markup for a byline with specified attributes.
      class MarkupBuilder
        # Content differentiating listing of a published post from that of a
        # draft post.
        module PublishedParts
          include Contracts

          Contract None => String
          def status
            'Posted'
          end

          Contract None => ActiveSupport::TimeWithZone
          def what_time
            attributes.pubdate
          end
        end
      end # class Decorations::Posts::BylineBuilder::MarkupBuilder
    end # class Decorations::Posts::BylineBuilder
  end
end
