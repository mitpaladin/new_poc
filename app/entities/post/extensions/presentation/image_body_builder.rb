
require_relative 'body_builder_base'

module Entity
  # The Post class encapsulates post-related domain logic of our "fancy" blog.
  # It delegates or defers implementation-specific details such as persistence,
  # user interface, etc.
  class Post
    # Presentation-ish methods used by current Post entity API.
    module Extensions
      # Presentation-oriented "decorator" methods and support.
      module Presentation
        # Body-builder class for image posts.
        class ImageBodyBuilder < BodyBuilderBase
          def build(post)
            build_document
            build_figure
            build_image(post.image_url)
            build_figcaption(post.body)
            convert_to_html
          end

          private

          attr_reader :doc, :figure

          def body_markup(markup)
            markdown_converter.to_html markup
          end

          def build_document
            @doc = Nokogiri::HTML::Document.new
          end

          def build_element(tag)
            Nokogiri::XML::Element.new tag, doc
          end

          def build_figcaption(body)
            figure << build_element('figcaption').tap do |figcaption|
              figcaption << body_markup(body)
            end
          end

          def build_figure
            @figure = build_element 'figure'
          end

          def build_image(image_url)
            figure << build_element('img').tap { |img| img[:src] = image_url }
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
          def convert_to_html
            figure.to_html save_with: 70
          end
        end # class Entity::Post::ImageBodyBuilder
      end
    end
  end # class Entity::Post
end
