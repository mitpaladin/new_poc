
# PostDecorator: Draper Decorator, aka ViewModel, for the Post model.
class PostDecorator < Draper::Decorator
  module SupportClasses
    # Base class for text/image post body builders.
    class BodyBuilder
      def initialize(h)
        @h = h
      end

      protected

      attr_reader :h
    end # class BodyBuilder
  end # module PostDecorator::SupportClasses
end # class PostDecorator
