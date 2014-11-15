
# Formerly included in a Draper decorator, when we used those pervasively.
class PostEntity
  module SupportClasses
    # Build image-post body.
    class ImageBodyBuilder
      # Note that since Markdown has no specific support for the :figure, :img,
      # or :figcaption tags beyond being a superset of HTML (valid HTML in a
      # Markdown document should be processed correctly), we're leaving the
      # `#build` method as is here.
      def build(obj)
        doc = Nokogiri::HTML::Document.new
        figure = Nokogiri::XML::Element.new 'figure', doc

        img = Nokogiri::XML::Element.new 'img', doc
        img[:src] = obj.image_url
        figure << img

        figcaption = Nokogiri::XML::Element.new 'figcaption', doc
        figcaption << body_markup(obj.body)
        figure << figcaption
        figure.to_html
      end

      private

      def body_markup(markup)
        MarkdownHtmlConverter.new.to_html(markup)
        # markup
      end
    end # class ImageBodyBuilder
  end # module SupportClasses
end # class PostEntity
