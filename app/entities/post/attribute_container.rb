
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
      def initialize(inputs = nil)
        @inputs = inputs.to_hash || {}
        @blacklist = []
        @whitelist = []
      end

      def attributes
        return @attributes if @attributes
        @attributes = value_object_for filtered_inputs
      end

      def blacklist(attribs)
        fail 'Too late to blacklist existing attributes' if @attributes
        @blacklist = attribs.map(&:to_sym)
        self
      end

      def define_methods(target)
        attributes.fields.each { |field| add_reader_method target, field }
        self
      end

      def whitelist(attribs)
        fail 'Too late to whitelist existing attributes' if @attributes
        @whitelist = attribs.map(&:to_sym)
        self
      end

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

      def add_reader_method(target, field)
        attrs = attributes
        target.class_eval do
          define_method field do
            attrs.send field
          end
        end
      end

      def filtered_inputs
        @inputs.reject { |k, _v| @blacklist.include? k }.tap do |inputs|
          unless @whitelist.empty?
            inputs.select! { |k, _v| @whitelist.include? k }
          end
        end
      end

      def value_object_for(attributes_in)
        # NOTE: #deep_symbolize_keys is a Railsism; see [this note](http://apidock.com/rails/Hash/deep_symbolize_keys#1505-Does-not-symbolize-hashes-in-nested-arrays)
        # on apidock.com.
        # NOTE: Passing in something non-Hash-like will die, messily. YHBW.
        a = attributes_in ? attributes_in.to_hash.deep_symbolize_keys : {}
        Class.new(ValueObject::Base) do
          has_fields(*(a.keys))
        end.new a
      end
    end # class Entity::Post::AttributeContainer
  end # class Entity::Post
end
