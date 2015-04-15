
require 'timestamp_builder'

# POROs that act as presentational support for entities.
module Decorations
  # Decorations for `Post` entities. D'oh!
  module Posts
    # Builds an HTML fragment (a paragraph) containing a timestamp and author-
    # name attribution.
    class BylineBuilder
      # Builds presentational markup for a byline with specified attributes.
      class MarkupBuilder
        # Base class for generating content for draft- or published-post byline.
        class PartsBase
          include TimestampBuilder

          attr_reader :attributes
          def initialize(attributes)
            @attributes = attributes
          end

          def content
            [status, timestamp_for(what_time), 'by', attributes.author_name]
              .join ' '
          end

          def status
            fail 'Must override #status in a subclass of PortsBase'
          end

          def what_time
            fail 'Must override #what_time in a subclass of PortsBase'
          end
        end # class Decorations::Posts::BylineBuilder::MarkupBuilder::PartsBase
      end # class Decorations::Posts::BylineBuilder::MarkupBuilder
    end # class Decorations::Posts::BylineBuilder
  end
end
