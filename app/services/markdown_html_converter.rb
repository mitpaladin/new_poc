
require 'rouge/plugins/redcarpet'

# Convert possibly mixed Markdown/HTML content to HTML.
class MarkdownHtmlConverter
  # `fragment` is Markdown, HTML or some combination thereof; run it through
  # RedCarpet's Markdown parser to yield HTML to return to caller.
  def to_html(fragment)
    render_using_redcarpet fragment
  end

  private

  # Old RedCarpet/Rouge-based code for Markdown parsing, etc. To be replaced.
  module RedCarpetConverter
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
  end # module MarkdownHtmlConverter::RedCarpetConverter

  def render_using_redcarpet(fragment)
    extend RedCarpetConverter
    # Do explicit String cast to convert any incoming nil to empty string.
    create_renderer.render String(fragment)
  end
end # class MarkdownHtmlConverter
