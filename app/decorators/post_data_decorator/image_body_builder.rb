
require_relative 'body_builder'
require_relative 'content_converter'

# PostDataDecorator: Draper Decorator, aka ViewModel, for the Post model.
class PostDataDecorator < Draper::Decorator
  module SupportClasses
    # Build image-post body. Called on behalf of PostDataDecorator#build_body.
    class ImageBodyBuilder < BodyBuilder
      # Note that since Markdown has no specific support for the :figure, :img,
      # or :figcaption tags beyond being a superset of HTML (valid HTML in a
      # Markdown document should be processed correctly), we're leaving the
      # `#build` method as is here.
      def build(obj)
        h.content_tag(:figure) do
          h.concat image_tag(obj)
          h.concat figcaption(obj)
        end # h.content_tag(:figure)
      end

      private

      def body_markup(markup)
        ContentConverter.new.to_html(markup)
        # markup
      end

      def figcaption(obj)
        h.content_tag :figcaption, body_markup(obj.body), nil, false
      end

      def image_tag(obj)
        h.tag(:img, src: obj.image_url)
      end
    end # class ImageBodyBuilder
  end # module SupportClasses
end # class PostDataDecorator
