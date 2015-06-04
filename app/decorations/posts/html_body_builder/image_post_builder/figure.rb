
require 'contracts'

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
        # Wraps building an HTML :figure element, which then ought to have its
        # `figcaption` and `img` attributes set before calling the `#to_html`
        # method.
        class Figure
          include Contracts

          attr_writer :figcaption, :img

          Contract None => Figure
          def initialize
            Ox.default_options = { indent: 0, encoding: 'UTF-8' }
            self
          end

          Contract None => String
          def to_html
            Ox.dump(native).tr "\n", ''
          end

          Contract None => Ox::Element
          def native
            Ox::Element.new('figure') << img << figcaption
          end

          private

          attr_reader :figcaption, :img
        end # class ...::Posts::HtmlBodyBuilder::ImagePostBuilder::Figure
      end # class Decorations::Posts::HtmlBodyBuilder::ImagePostBuilder
    end # class Decorations::Posts::HtmlBodyBuilder
  end
end
