
# Formerly included in a Draper decorator, when we used those pervasively.
class PostEntity
  module SupportClasses
    # Build text post body.
    class TextBodyBuilder
      def build(obj)
        "\n#{obj.body}\n"
      end
    end # class TextBodyBuilder
  end # module SupportClasses
end # class PostEntity
