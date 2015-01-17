
module Newpoc
  module Entity
    # a Post is the domain entity for a blog-type post, with title, body, etc.
    class Post
      module SupportClasses
        # Build image-post body.
        class ImageBodyBuilder
          def initialize(markdown_converter = default_markdown_converter)
            @markdown_converter = markdown_converter
          end

          # Note that since Markdown has no specific support for the
          # :figure, :img, or :figcaption tags beyond being a superset of
          # HTML (valid HTML in a Markdown document should be processed
          # correctly), we're leaving the `#build` method as is here.
          def build(obj)
            doc = build_document
            # FIXME: Feature envy for `figure`.
            figure = build_figure doc
            figure << build_image(doc, obj.image_url)
            figure << build_figcaption(doc, obj.body)
            convert_to_html figure
          end

          private

          attr_reader :markdown_converter

          def default_markdown_converter
            lambda do |markup|
              require 'newpoc/services/markdown_html_converter'
              Newpoc::Services::MarkdownHtmlConverter.new.to_html markup
            end
          end

          # NOTE: This method *must* be mocked by unit tests, as the converter
          #       is now part of a different Gem (that can't be required as a
          #       dependency at present).
          def body_markup(markup)
            markdown_converter.call markup
          end

          def build_document
            Nokogiri::HTML::Document.new
          end

          def build_figcaption(doc, body)
            Nokogiri::XML::Element.new('figcaption', doc).tap do |figcaption|
              figcaption << body_markup(body)
            end
          end

          def build_figure(doc)
            Nokogiri::XML::Element.new 'figure', doc
          end

          def build_image(doc, image_url)
            tag = Nokogiri::XML::Element.new('img', doc).tap do |img|
              img[:src] = image_url
            end
            markdown_converter.call tag.to_html
          end

          # Adapted from the Nokogiri Github `/wiki/Cheat-sheet` page at the
          # section "Working with a Nokogiri::XML::Node" (scroll down near the
          # bottom of that section). The value '70' comes from adding the values
          #   * NO_DECLARATION (2);
          #   * NO_EMPTY_TAGS (4);
          #   * AS_HTML (64).
          # It *does not* include `FORMAT` (1), which *is* included in the
          # DEFAULT_HTML bitmask.
          #
          # Discovering this took much too much too long, and involved
          # navigating past an oddy-empty "Generating HTML" page on the Nokogiri
          # Github Wiki page.
          def convert_to_html(node)
            node.to_html save_with: 70
          end
        end # class Newpoc::Entity::Post::SupportClasses::ImageBodyBuilder
      end # module Newpoc::Entity::Post::SupportClasses
    end # class Newpoc::Entity::Post
  end # module Newpoc::Entity
end # module Newpoc
