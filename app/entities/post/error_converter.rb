
# Namespace containing all application-defined entities.
module Entity
  # The Post class encapsulates post-related domain logic of our "fancy" blog.
  # It delegates or defers implementation-specific details such as persistence,
  # user interface, etc.
  class Post
    class ErrorConverter
      extend ActiveModel::Naming

      def initialize(error_hashes)
        @errors = ActiveModel::Errors.new self
        error_hashes.each do |error_hash|
          errors.add error_hash.keys.first, error_hash.values.first
        end
      end

      attr_reader :errors

      # Following 3 methods are boilerplate required by ActiveModel::Errors

      def read_attribute_for_validation(attr)
        send(attr)
      end

      def self.human_attribute_name(attr, options = {})
        # If attr is :panic_button, options[default] should be 'Panic button'
        options[:default] || attr
      end

      def self.lookup_ancestors
        [self]
      end
    end # class Entity::Post::ErrorConverter
    private_constant :ErrorConverter
  end # class Entity::Post
end
