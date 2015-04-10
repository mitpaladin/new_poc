
require_relative 'either_required_field_validator'

# Namespace containing all application-defined entities.
module Entity
  # The Post class encapsulates post-related domain logic of our "fancy" blog.
  # It delegates or defers implementation-specific details such as persistence,
  # user interface, etc.
  class Post
    # Validates body attribute, providing #valid? and #errors public methods
    # that work generally as you'd expect.
    class BodyValidator < EitherRequiredFieldValidator
      def initialize(attributes)
        super attributes: attributes, primary: :body, other: :image_url
      end
    end # class Entity::Post::BodyValidator
  end # class Entity::Post
end
