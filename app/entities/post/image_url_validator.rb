
# Namespace containing all application-defined entities.
module Entity
  # The Post class encapsulates post-related domain logic of our "fancy" blog.
  # It delegates or defers implementation-specific details such as persistence,
  # user interface, etc.
  class Post
    # Validates image URL attribute, providing #valid? and #errors public
    # methods that work generally as you'd expect.
    class ImageUrlValidator
      def initialize(attributes)
        @image_url = attributes.to_hash[:image_url].to_s.strip
        @body_empty = attributes.to_hash[:body].to_s.strip.empty?
        @errors = []
      end

      def errors
        valid?
        @errors
      end

      def valid?
        @errors = []
        return true unless both_fields_empty?
        @errors.push error_entry
        false
      end

      private

      attr_reader :body_empty, :image_url

      def both_fields_empty?
        body_empty && image_url.empty?
      end

      def error_entry
        { image_url: 'may not be empty if body is missing or empty' }
      end
    end # class Entity::Post::BodyValidator
  end # class Entity::Post
end
