
# Namespace containing all application-defined entities.
module Entity
  # The Post class encapsulates post-related domain logic of our "fancy" blog.
  # It delegates or defers implementation-specific details such as persistence,
  # user interface, etc.
  class Post
    # Validates title attribute, providing #valid? and #errors public methods
    # that work generally as you'd expect.
    class TitleValidator
      def initialize(attributes)
        @title = attributes.to_hash[:title]
        @errors = []
      end

      def errors
        valid?
        @errors
      end

      def valid?
        return true if title.present?
        @errors = []
        add_error 'must be present'
        false
      end

      private

      attr_reader :title

      def add_error(message)
        entry = { title: message }
        @errors.push entry
      end
    end # class Entity::Post::TitleValidator
  end # class Entity::Post
end
