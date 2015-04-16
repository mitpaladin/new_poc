
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
          def initialize(doc:, image_url:)
            super doc
            @image_url = image_url
          end

          def to_html
            element('img').tap { |img| img[:src] = @image_url }
          end
        end # class Decorations::Posts::HtmlBodyBuilder::ImagePostBuilder::Image
      end # class Decorations::Posts::HtmlBodyBuilder::ImagePostBuilder
    end # class Decorations::Posts::HtmlBodyBuilder
  end
end
