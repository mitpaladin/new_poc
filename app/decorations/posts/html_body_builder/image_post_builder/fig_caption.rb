
require 'nokogiri'

require 'markdown_html_converter'

require_relative 'element'

# POROs that act as presentational support for entities.
module Decorations
  # Decorations for `Post` entities. D'oh!
  module Posts
    # The `HtmlBodyBuilder` `Post` decoration builds an HTML representation of
    # the body of the `post` instance passed into the `#build` method. That
    # representation will be either
    #
    # 1. the post body as HTML, if there is no `image_url` on the `Post`; or
    # 2. the post body and image URL within a `figure`; see #build for details.
    #
    class HtmlBodyBuilder
      # Builds image-post body, with HTML :img and :figcaption wrapped in a
      # :figure.
      class ImagePostBuilder
        # Wraps building an HTML :figcaption element from a Markdown post body
        # (remembering that HTML is a valid subset of Markdown).
        class FigCaption < Element
          def initialize(doc:, content:)
            super doc
            @content = content
          end

          def to_html
            node = element('figcaption').tap { |container| container << markup }
            node.to_html
          end

          private

          attr_reader :content

          def markup
            MarkdownHtmlConverter.new.to_html content
          end
        end # class ...::Posts::HtmlBodyBuilder::ImagePostBuilder::FigCaption
      end # class Decorations::Posts::HtmlBodyBuilder::ImagePostBuilder
    end # class Decorations::Posts::HtmlBodyBuilder
  end
end
