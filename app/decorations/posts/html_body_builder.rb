
require 'contracts'

require 'markdown_html_converter'

require_relative 'html_body_builder/image_post_builder'

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
      include Contracts

      # Overriding the default `markdown_converter` parameter is mostly
      # useful for situations where the app makes use of Pivotal's "unbuilt
      # Rails dependency" idiom. As we're no longer doing that, we *could*
      # just rip it out entirely. One step at a time.
      Contract Maybe[RespondTo[:to_html]] => HtmlBodyBuilder
      def initialize(markdown_converter = default_markdown_converter)
        @markdown_converter = markdown_converter
        return self if markdown_converter.respond_to? :to_html
        fail ArgumentError, 'parameter must respond to the :to_html message'
      end

      # Builds an HTML representation of the post contents, in a format that
      # depends on whether the `Post`'s `image_url` attribute is present.
      #
      # With no image URL, converts the post body (which may contain any valid
      # combination of text and Markdown formatting (which allows raw HTML)) to
      # HTML, and returns that.
      #
      # *With* an image URL, generates an HTML `figure` tag pair containing the
      # image URL wrapped in an `img` tag pair, and a `figcaption` tag pair
      # containing the (converted) post body, returning the generated `figure`
      # fragment.
      Contract RespondTo[:title, :body] => String
      def build(post)
        @post = post
        return body_markup(post.body) if text_post?
        build_image_post
      end

      private

      attr_reader :markdown_converter, :post

      Contract String => String
      def body_markup(markup)
        markdown_converter.to_html markup
      end

      Contract None => String
      def build_image_post
        ImagePostBuilder.new(image_url: post.image_url,
                             body_html: body_markup(post.body)).to_html
      end

      Contract None => MarkdownHtmlConverter
      def default_markdown_converter
        MarkdownHtmlConverter.new
      end

      Contract None => Bool
      def text_post?
        post.image_url.blank?
      end
    end # class Decorations::Posts::HtmpBodyBuilder
  end
end
