
# Namespace containing all application-defined entities.
module Entity
  # The Post class encapsulates post-related domain logic of our "fancy" blog.
  # It delegates or defers implementation-specific details such as persistence,
  # user interface, etc.
  class Post
    # Contains attributes for an Entity class instance, isolating containing
    # class from change per [this comment](https://github.com/jdickey/new_poc/pull/254#issuecomment-90134058)
    # on PR #254.
    class AttributeContainer
      attr_reader :attributes

      def initialize(attributes)
        a = Hash(attributes)
        @attributes = Class.new(ValueObject::Base) do
          has_fields(*(a.keys))
        end.new a
      end
    end # class Entity::Post::AttributeContainer
  end # class Entity::Post
end
