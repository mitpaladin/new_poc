
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
        # Wraps building an HTML :img element from an "image url" string.
        class Image < Element
          module Internals
            def default_converter
              MarkdownHtmlConverter.new
            end
          end
          extend Internals
          include Contracts

          attr_init :doc, :image_url, markdown_converter: default_converter do
            validate_initialisers! doc, image_url, markdown_converter
          end

          Contract None => String
          def to_html
            markup = element('img').tap { |img| img[:src] = @image_url }
            markdown_converter.to_html markup.to_html
          end

          private

          Contract Nokogiri::HTML::Document, String,
                   MarkdownHtmlConverter => Bool
          def validate_initialisers!(_doc, _image_url, _converter)
            true
          end
        end # class Decorations::Posts::HtmlBodyBuilder::ImagePostBuilder::Image
      end # class Decorations::Posts::HtmlBodyBuilder::ImagePostBuilder
    end # class Decorations::Posts::HtmlBodyBuilder
  end
end
