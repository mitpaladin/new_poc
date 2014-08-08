
require_relative 'body_builder'

# PostDataDecorator: Draper Decorator, aka ViewModel, for the PostData model.
class PostDataDecorator < Draper::Decorator
  module SupportClasses
    # Build text post body. Called on behalf of PostDataDecorator#build_body.
    class TextBodyBuilder < BodyBuilder
      def build(obj)
        "\n#{obj.body}\n"
      end
    end # class TextBodyBuilder
  end # module SupportClasses
end # class PostDataDecorator
