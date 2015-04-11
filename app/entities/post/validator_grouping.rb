
require_relative 'body_validator'
require_relative 'image_url_validator'
require_relative 'title_validator'

# Namespace containing all application-defined entities.
module Entity
  # The Post class encapsulates post-related domain logic of our "fancy" blog.
  # It delegates or defers implementation-specific details such as persistence,
  # user interface, etc.
  class Post
    # Isolates validation objects and groups them together so that an entity
    # can simply delegate `#errors` and `#valid` to an instance of this class,
    # and not change when a new validator is added or an existing one changed.
    # It also supports adding new validators that quack like the existing ones
    # (attribute-based initialisation with `#errors` and `#valid?` methods).
    class ValidatorGrouping
      def initialize(attributes)
        @validators = {}
        add :title, TitleValidator.new(attributes)
        add :body, BodyValidator.new(attributes)
        add :image_url, ImageUrlValidator.new(attributes)
      end

      def add(key, validator)
        @validators[key] = validator
        self
      end

      def errors
        validators.values.inject([]) { |a, e| a + e.errors }
      end

      def valid?
        validators.select { |_k, validator| !validator.valid? }.empty?
      end

      private

      attr_reader :validators
    end # class Entity::Post::ValidatorGrouping
  end # class Entity::Post
end
