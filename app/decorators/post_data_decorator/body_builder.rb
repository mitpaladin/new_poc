
# PostDataDecorator: Draper Decorator, aka ViewModel, for the Post model.
class PostDataDecorator < Draper::Decorator
  module SupportClasses
    # Base class for text/image post body builders.
    class BodyBuilder
      def initialize(h)
        @h = h
      end

      protected

      attr_reader :h
    end # class BodyBuilder
  end # module PostDataDecorator::SupportClasses
end # class PostDataDecorator
