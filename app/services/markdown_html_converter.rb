
require 'html/pipeline'
require 'pygments'

# Convert possibly mixed Markdown/HTML content to HTML.
class MarkdownHtmlConverter
  # HTML::Pipeline-based code for Markdown parsing.
  module HtmlPipelineConverter
    # Internal workings that needn't be visible to caller of `.render`.
    module Internals
      def self.context
        {
          gfm: true,
          asset_root: '/images', # for emoji
          base_url: 'https://github.com/' # for @mentions
        }
      end

      def self.filters
        [
          HTML::Pipeline::MarkdownFilter,
          # HTML::Pipeline::SanitizationFilter,
          # HTML::Pipeline::CamoFilter,
          HTML::Pipeline::ImageMaxWidthFilter,
          # HTML::Pipeline::HttpsFilter,
          HTML::Pipeline::MentionFilter,
          HTML::Pipeline::EmojiFilter,
          HTML::Pipeline::SyntaxHighlightFilter,
          HTML::Pipeline::AutolinkFilter
        ]
      end

      def self.pipeline
        HTML::Pipeline.new filters, context
      end
    end # module MarkdownHtmlConverter::HtmlPipelineConverter::Internals
    private_constant :Internals

    def self.render(fragment)
      result = Internals.pipeline.call fragment
      result[:output]
    end
  end # module MarkdownHtmlConverter::HtmlPipelineConverter
  private_constant :HtmlPipelineConverter

  # `fragment` is Markdown, HTML or some combination thereof; run it through
  # the selected Markdown parser to yield HTML to return to caller.
  def to_html(fragment)
    HtmlPipelineConverter.render fragment
  end
end # class MarkdownHtmlConverter
