
require 'newpoc/services/markdown_html_converter'

# Namespace containing all application-defined entities.
module Entity
  # The Post class encapsulates post-related domain logic of our "fancy" blog.
  # It delegates or defers implementation-specific details such as persistence,
  # user interface, etc.
  class Post
    # Body-builder class for image posts.
    class ImageBodyBuilder
      # Overriding the default `markdown_converter` parameter is mostly useful
      # for situations where the app makes use of Pivotal's "unbuilt Rails
      # dependency" idiom. As we're no longer doing that, we *could* just rip it
      # out entirely. One step at a time.
      def initialize(markdown_converter = default_markdown_converter)
        @markdown_converter = markdown_converter
      end

      def build(post)
        doc = build_document
        # FIXME: Feature envy for `figure`.
        figure = build_figure doc
        figure << build_image(doc, post.image_url)
        figure << build_figcaption(doc, post.body)
        convert_to_html figure
      end

      private

      attr_reader :markdown_converter

      def default_markdown_converter
        Newpoc::Services::MarkdownHtmlConverter.new
      end

      def body_markup(markup)
        markdown_converter.to_html markup
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
        Nokogiri::XML::Element.new('img', doc).tap do |img|
          img[:src] = image_url
        end
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
    end # class Entity::Post::ImageBodyBuilder
  end # class Entity::Post
end
