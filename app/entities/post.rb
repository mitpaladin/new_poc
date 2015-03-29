
require 'value_object'

require_relative 'post/attribute_extension_mapper'
require_relative 'post/extensions/persistence'
require_relative 'post/extensions/presentation'
require_relative 'post/extensions/validation'

# Namespace containing all application-defined entities.
module Entity
  # The Post class encapsulates post-related domain logic of our "fancy" blog.
  # It delegates or defers implementation-specific details such as persistence,
  # user interface, etc.
  class Post
    extend Forwardable

    # Value object containing attribute definitions used by this class.
    class CoreAttributes < ValueObject::Base
      has_fields :author_name, :body, :image_url, :pubdate, :title
    end
    private_constant :CoreAttributes

    def extend_with_presentation
      extend Extensions::Presentation
    end

    def extend_with_validation
      extend Extensions::Validation
    end

    def initialize(attributes)
      @attributes = {}
      @attributes[:core] = CoreAttributes.new attributes
      @extension_mapper = AttributeExtensionMapper.new.build do |mapping|
        mapping[:core] = CoreAttributes.fields
      end
      @attributes_in = attributes
      load_extensions attributes
    end

    def instance_variable_set(_symbol, _obj)
      fail "Can't touch this."
    end

    def method_missing(method_sym, *arguments, &block)
      return super unless @extension_mapper[method_sym].present?
      # We're asking for an attribute; let's define a reader for it so we
      # don't come here again looking for that attribute
      attr_set_index = ext_index_symbol_for method_sym
      attribute_set = @attributes[attr_set_index]
      define_singleton_method method_sym do
        # Extension not loaded because triggering attributes not set. Bail.
        return nil unless attribute_set.respond_to? method_sym
        # We're alive; carry on.
        attribute_set.send method_sym
      end
      send method_sym
    end

    def respond_to?(method, include_private = false)
      super || @extension_mapper[method].present?
    end

    def attributes
      all_attributes = collect_attributes
      # Right; we've a *Hash* of every attribute in the entity; but what we
      # really want is a *ValueObject*.
      attributes_class(all_attributes.keys).new all_attributes
    end

    def persisted?
      slug.present?
    end

    private

    def attributes_class(attribute_keys)
      Class.new(ValueObject::Base).tap do |ret|
        attribute_keys.each { |key| ret.instance_eval { has_fields key } }
      end
    end

    def collect_attributes
      {}.tap do |all_attributes|
        @attributes.each_key do |attributes_set|
          all_attributes.merge! @attributes[attributes_set].to_hash
        end
      end
    end

    def ext_index_symbol_for(method_sym)
      @extension_mapper[method_sym].to_s.split('::').last.downcase.to_sym
    end

    def load_extensions(attributes)
      attributes.each_key do |k|
        extension = @extension_mapper[k]
        next if [nil, :core].include?(extension)
        extend extension
      end
    end
  end # class Entity::Post
end
