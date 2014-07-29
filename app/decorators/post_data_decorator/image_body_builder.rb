
require_relative 'body_builder'

# PostDataDecorator: Draper Decorator, aka ViewModel, for the Post model.
class PostDataDecorator < Draper::Decorator
  module SupportClasses
    # Build image-post body. Called on behalf of PostDataDecorator#build_body.
    class ImageBodyBuilder < BodyBuilder
      def build(obj)
        h.content_tag(:figure) do
          h.concat image_tag(obj)
          h.concat figcaption(obj)
        end # h.content_tag(:figure)
      end

      private

      def figcaption(obj)
        h.content_tag :figcaption, obj.body, nil, false
      end

      def image_tag(obj)
        h.tag(:img, src: obj.image_url)
      end
    end # class ImageBodyBuilder
  end # module SupportClasses
end # class PostDataDecorator
