
require 'rouge/plugins/redcarpet'

# Convert possibly mixed Markdown/HTML content to HTML.
class MarkdownHtmlConverter
  # Old RedCarpet/Rouge-based code for Markdown parsing, etc. To be replaced.
  module RedCarpetConverter
    # Internals that are a don't-care for the containing class.
    module Internals
      # Redcarpet Markdown output renderer. Uses Rouge for syntax highlighting.
      class RCRenderer < Redcarpet::Render::HTML
        include Rouge::Plugins::Redcarpet
      end

      def self.rc_conversion_options
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

      def self.rc_create_renderer
        Redcarpet::Markdown.new RCRenderer, rc_conversion_options
      end
    end # module MarkdownHtmlConverter::RedCarpetConverter::Internals
    private_constant :Internals

    def self.render(fragment)
      # Do explicit String cast to convert any incoming nil to empty string.
      Internals.rc_create_renderer.render String(fragment)
    end
  end # module MarkdownHtmlConverter::RedCarpetConverter
  private_constant :RedCarpetConverter

  # `fragment` is Markdown, HTML or some combination thereof; run it through
  # RedCarpet's Markdown parser to yield HTML to return to caller.
  def to_html(fragment)
    RedCarpetConverter.render fragment
  end

  attr_writer :debug_flag

  private

  # HTML::Pipeline-based code for Markdown parsing. Replaces RedCarpetConverter.
  module HtmlPipelineConverter
    def hpc_context
      {
        gfm: true,
        asset_root: '/images', # for emoji
        base_url: 'https://github.com/' # for @mentions
      }
    end

    def hpc_filters
      [
        HTML::Pipeline::MarkdownFilter,
        HTML::Pipeline::SanitizationFilter,
        # HTML::Pipeline::CamoFilter,
        HTML::Pipeline::ImageMaxWidthFilter,
        # HTML::Pipeline::HttpsFilter,
        HTML::Pipeline::MentionFilter,
        HTML::Pipeline::EmojiFilter,
        HTML::Pipeline::SyntaxHighlightFilter,
        HTML::Pipeline::AutolinkFilter
      ]
    end

    def hpc_pipeline
      HTML::Pipeline.new hpc_filters, hpc_context
    end
  end # module MarkdownHtmlConverter::HtmlPipelineConverter

  def render_using_pipeline(fragment)
    extend HtmlPipelineConverter

    result = hpc_pipeline.call fragment
    ap [:line_72, fragment, result]
  end
end # class MarkdownHtmlConverter
