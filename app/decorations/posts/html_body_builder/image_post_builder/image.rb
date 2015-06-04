
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
        # Wraps building an HTML :img element from an "image url" string.
        class Image
          include Contracts

          Contract String => Image
          def initialize(image_url)
            @image_url = image_url
            self
          end

          Contract None => Ox::Element
          def native
            Ox::Element.new('img').tap { |img| img[:src] = @image_url }
          end

          Contract None => String
          def to_html
            content = Ox.dump(native).tr("\n", '')
            markup = MarkdownHtmlConverter.new.to_html content
            with_repaired_img_tags_in markup
          end

          private

          # Ox has a problem parsing converter-generated markup for an :img tag,
          # because the `HTML::Pipeline::ImageMaxWidthFilter` does *not*
          # generate an auto-closed `<img... />` tag. Hence, this method; paring
          # the output of which will work correctly in Ox (or anything else).
          Contract String => String
          def with_repaired_img_tags_in(input)
            parts = input.split(/<img.+?>/)
            matches = input.match(/(<img.+?)>/)
            return input unless matches
            joints = matches.captures.map { |s| s + '/>' }
            parts.zip(joints).flatten.compact.join
          end
        end # class Decorations::Posts::HtmlBodyBuilder::ImagePostBuilder::Image
      end # class Decorations::Posts::HtmlBodyBuilder::ImagePostBuilder
    end # class Decorations::Posts::HtmlBodyBuilder
  end
end
