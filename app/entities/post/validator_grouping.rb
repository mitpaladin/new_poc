
require_relative 'validators/body'
require_relative 'validators/image_url'
require_relative 'validators/title'
require_relative 'validator_grouping/discoverer'

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
        Discoverer.new(self).each { |k, v| add k, v.new(attributes) }
      end

      def add(key, validator)
        validators[key] = validator
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
