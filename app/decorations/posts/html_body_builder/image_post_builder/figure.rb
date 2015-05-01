
require 'contracts'

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
        include Contracts

        # Wraps building an HTML :figure element, which then ought to have its
        # `figcaption` and `img` attributes set before calling the `#to_html`
        # method.
        class Figure < Element
          attr_init :doc, :figcaption, :img do
            validate_initialisers! doc, figcaption, img
          end

          Contract None => String
          def to_html
            element('figure').tap do |figure|
              figure << img << figcaption
            end.to_html save_with: html_save_options
          end

          private

          Contract Nokogiri::HTML::Document, String, String => Bool
          def validate_initialisers!(_doc, _figcaption, _img)
            true
          end
        end # class ...::Posts::HtmlBodyBuilder::ImagePostBuilder::Figure
      end # class Decorations::Posts::HtmlBodyBuilder::ImagePostBuilder
    end # class Decorations::Posts::HtmlBodyBuilder
  end
end
