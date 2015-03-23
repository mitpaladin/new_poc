
require 'newpoc/services/markdown_html_converter'

# Namespace containing all application-defined entities.
module Entity
  # The Post class encapsulates post-related domain logic of our "fancy" blog.
  # It delegates or defers implementation-specific details such as persistence,
  # user interface, etc.
  class Post
    # Body-builder class for text posts
    class TextBodyBuilder
      # Overriding the default `markdown_converter` parameter is mostly useful
      # for situations where the app makes use of Pivotal's "unbuilt Rails
      # dependency" idiom. As we're no longer doing that, we *could* just rip it
      # out entirely. One step at a time.
      def initialize(markdown_converter = default_markdown_converter)
        @markdown_converter = markdown_converter
      end

      def build(post)
        markdown_converter.to_html post.body
      end

      private

      attr_reader :markdown_converter

      def default_markdown_converter
        Newpoc::Services::MarkdownHtmlConverter.new
      end
    end # class Entity::Post::TextBodyBuilder
  end # class Entity::Post
end