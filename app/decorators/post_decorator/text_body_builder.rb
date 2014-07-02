
require_relative 'body_builder'

# PostDecorator: Draper Decorator, aka ViewModel, for the Post model.
class PostDecorator < Draper::Decorator
  module SupportClasses
    # Build body for a text post. Called on behalf of PostDecorator#build_body.
    class TextBodyBuilder < BodyBuilder
      def build(obj)
        h.content_tag :p, obj.body
      end
    end # class TextBodyBuilder
  end # module SupportClasses
end # class PostDecorator
