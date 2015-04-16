
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
        # Base class to wrap building an HTML element using Nokogiri. MUST
        # override the `#to_html` method.
        class Element
          def initialize(doc)
            @doc = doc
          end

          def to_html
            fail 'Must override #to_html in a subclass'
          end

          # protected

          attr_reader :doc

          def element(tag)
            Nokogiri::XML::Element.new tag, doc
          end

          def html_save_options
            so = Nokogiri::XML::Node::SaveOptions
            so::AS_HTML + so::NO_DECLARATION + so::NO_EMPTY_TAGS
          end
        end # class ...::Posts::HtmlBodyBuilder::ImagePostBuilder::Element
      end # class Decorations::Posts::HtmlBodyBuilder::ImagePostBuilder
    end # class Decorations::Posts::HtmlBodyBuilder::ImagePostBuilder
  end
end
