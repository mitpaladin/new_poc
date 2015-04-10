
require_relative 'either_required_field_validator'

# Namespace containing all application-defined entities.
module Entity
  # The Post class encapsulates post-related domain logic of our "fancy" blog.
  # It delegates or defers implementation-specific details such as persistence,
  # user interface, etc.
  class Post
    # Validates image URL attribute, providing #valid? and #errors public
    # methods that work generally as you'd expect.
    class ImageUrlValidator < EitherRequiredFieldValidator
      def initialize(attributes)
        super attributes: attributes, primary: :image_url, other: :body
      end
    end # class Entity::Post::ImageUrlValidator
  end # class Entity::Post
end
