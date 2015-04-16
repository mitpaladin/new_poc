
require_relative 'image_post_builder/fig_caption'
require_relative 'image_post_builder/figure'
require_relative 'image_post_builder/image'

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
        def initialize(body_html:, image_url:)
          @body = body_html
          @image_url = image_url
          @doc = document
        end

        def to_html
          figure = Figure.new(doc)
          figure.figcaption = build_figcaption
          figure.img = build_image
          figure.to_html
        end

        private

        attr_reader :body, :doc, :image_url

        def build_figcaption
          FigCaption.new(doc: doc, body_html: body).to_html
        end

        def build_image
          Image.new(doc: doc, image_url: image_url).to_html
        end

        def document
          Nokogiri::HTML::Document.new
        end
      end # class Decorations::Posts::HtmlBodyBuilder::ImagePostBuilder
    end # class Decorations::Posts::HtmlBodyBuilder
  end
end
