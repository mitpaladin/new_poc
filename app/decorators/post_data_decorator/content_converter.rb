
require 'rouge/plugins/redcarpet'

# PostDataDecorator: Draper Decorator, aka ViewModel, for the PostData model.
class PostDataDecorator < Draper::Decorator
  module SupportClasses
    # Convert possibly mixed Markdown/HTML content to HTML.
    class ContentConverter
      # `fragment` is Markdown, HTML or some combination thereof; run it through
      # RedCarpet's Markdown parser to yield HTML to return to caller.
      def to_html(fragment)
        # Do explicit String cast to convert any incoming nil to empty string.
        create_renderer.render String(fragment)
      end

      private

      # Redcarpet Markdown output renderer. Uses Rouge for syntax highlighting.
      class Renderer < Redcarpet::Render::HTML
        include Rouge::Plugins::Redcarpet
      end

      def conversion_options
        {
          autolink:                     true,
          fenced_code_blocks:           true,
          highlight:                    true,
          no_intra_emphasis:            false,
          strikethrough:                true,
          superscript:                  true,
          tables:                       true,
          underline:                    true
        }
      end

      def create_renderer
        Redcarpet::Markdown.new Renderer, conversion_options
      end
    end
  end # module PostDataDecorator::SupportClasses
end # class PostDataDecorator
