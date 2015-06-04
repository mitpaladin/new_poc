
require 'contracts'

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
        include Contracts

        INIT_CONTRACT_INPUTS = {
          body_html: String,
          image_url: String
        }

        Contract INIT_CONTRACT_INPUTS => ImagePostBuilder
        def initialize(body_html:, image_url:)
          @body = body_html
          @image_url = image_url
          self
        end

        Contract None => String
        def to_html
          figure = Figure.new
          figure.figcaption = build_figcaption
          figure.img = build_image
          MarkdownHtmlConverter.new.to_html figure.to_html
        end

        private

        attr_reader :body, :doc, :image_url

        Contract None => Ox::Element
        def build_figcaption
          FigCaption.new(body).native
        end

        Contract None => Ox::Element
        def build_image
          Image.new(image_url).native
        end
      end # class Decorations::Posts::HtmlBodyBuilder::ImagePostBuilder
    end # class Decorations::Posts::HtmlBodyBuilder
  end
end
