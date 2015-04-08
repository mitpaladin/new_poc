
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
      extend Forwardable

      attr_reader :attributes

      def initialize(attributes_in = {})
        @attributes = value_object_for attributes_in.to_hash
      end

      def_delegator :@attributes, :fields, :keys

      def self.blacklist_from(source, *blacklisted_attrs)
        attributes = source.attributes.to_hash.reject do |k, _v|
          blacklisted_attrs.include? k
        end
        source.class.new attributes
      end

      def self.whitelist_from(source, *whitelisted_attrs)
        attributes = source.attributes.to_hash.select do |k, _v|
          whitelisted_attrs.include? k
        end
        source.class.new attributes
      end

      private

      def value_object_for(attributes_in)
        # NOTE: #deep_symbolize_keys is a Railsism; see [this note](http://apidock.com/rails/Hash/deep_symbolize_keys#1505-Does-not-symbolize-hashes-in-nested-arrays)
        # on apidock.com.
        # NOTE: Passing in something non-Hash-like will die, messily. YHBW.
        a = attributes_in.deep_symbolize_keys
        Class.new(ValueObject::Base) do
          has_fields(*(a.keys))
        end.new a
      end
    end # class Entity::Post::AttributeContainer
  end # class Entity::Post
end
