
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

        attr_init body: nil, image_url: nil do
          validate_initialisers! body, image_url
          @doc = Nokogiri::HTML::Document.new
        end

        Contract None => String
        def to_html
          Figure.new(doc, build_figcaption, build_image).to_html
        end

        private

        attr_reader :doc

        Contract None => String
        def build_figcaption
          FigCaption.new(doc, body).to_html
        end

        Contract None => String
        def build_image
          Image.new(doc, image_url).to_html
        end

        Contract Maybe[String], Maybe[String] => Bool
        def validate_initialisers!(_body, _image_url)
          true
        end
      end # class Decorations::Posts::HtmlBodyBuilder::ImagePostBuilder
    end # class Decorations::Posts::HtmlBodyBuilder
  end
end
