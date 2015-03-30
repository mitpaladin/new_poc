
require 'value_object'

# Namespace containing all application-defined entities.
module Entity
  # The Post class encapsulates post-related domain logic of our "fancy" blog.
  # It delegates or defers implementation-specific details such as persistence,
  # user interface, etc.
  class Post
    # Maintains a collection of value objects (of symbol/value-pair attributes)
    # and supports retrieving a value object of all attributes defined by each
    # entry in the collection.
    class AttributesSets
      extend Forwardable

      def_delegators :@sets, :[], :[]=
      # Each entry in `@sets` is a set, or list, of attributes, so...
      def_delegator :@sets, :each_value, :each_list

      def initialize
        @sets = {}
      end

      def to_value_object
        all_attributes = collect_all
        # Right; we've a *Hash* of every attribute in the entity; but what we
        # really want is a *ValueObject*.
        attributes_class(all_attributes.keys).new all_attributes
      end

      private

      def attributes_class(attribute_keys)
        Class.new(ValueObject::Base).tap do |ret|
          attribute_keys.each { |key| ret.instance_eval { has_fields key } }
        end
      end

      def collect_all
        {}.tap do |ret|
          @sets.each_value do |attributes_set|
            ret.merge! attributes_set.to_hash
          end
        end
      end
    end # class Entity::Post::AttributesSets
    private_constant :AttributesSets
  end # class Entity::Post
end
