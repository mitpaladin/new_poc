
require 'value_object'

require_relative 'post/attribute_extension_mapper'
require_relative 'post/attributes_sets'
require_relative 'post/extensions/persistence'
require_relative 'post/extensions/presentation'
require_relative 'post/extensions/validation'

# Namespace containing all application-defined entities.
module Entity
  # The Post class encapsulates post-related domain logic of our "fancy" blog.
  # It delegates or defers implementation-specific details such as persistence,
  # user interface, etc.
  class Post
    # Value object containing attribute definitions used by this class.
    class CoreAttributes < ValueObject::Base
      has_fields :author_name, :body, :image_url, :pubdate, :title
    end
    private_constant :CoreAttributes

    ############################################################################
    # Extensions
    #
    # Extensions come in two flavours, which I'm presently calling "functional"
    # and "optional". Functional extensions, such as Presentation or Validation,
    # add features (functionality) to the core entity. Optional extensions
    # provide support for attributes not part of the core attribute set, and are
    # added as a result of their attributes being specified as parameaters to
    # `#initialize` (see the `AttributeExtensionMapper` class and the
    # `#load_extensions` method of this class). Outside code working with entity
    # instances should and must be kept blissfully unaware of the internal
    # machinations going on; from its viewpoint, an attribute is an attribute.
    #
    # Continuing, functional extensions have corresponding methods on this class
    # which extend an instance of this class with the extension in question;
    # optional classes never do. (To load an optional extension, specify its
    # attributes when instantiating this class.)
    def extend_with_presentation
      extend Extensions::Presentation
    end

    def extend_with_validation
      extend Extensions::Validation
    end

    extend Forwardable

    def_delegator :@extension_mapper, :[], :extension_for

    def initialize(attributes)
      init_attribute_mapping(attributes)
      load_extensions
    end

    def instance_variable_set(_symbol, _obj)
      fail "Can't touch this."
    end

    def method_missing(method_sym, *arguments, &block)
      return super unless extension_for(method_sym).present?
      # We're asking for an attribute; let's define a reader for it so we
      # don't come here again looking for that attribute
      attr_set_index = ext_index_symbol_for method_sym
      attribute_set = attributes_sets[attr_set_index]
      define_singleton_method method_sym do
        # Extension not loaded because triggering attributes not set. Bail.
        return nil unless attribute_set.respond_to? method_sym
        # We're alive; carry on.
        attribute_set.send method_sym
      end
      send method_sym
    end

    def respond_to?(method, include_private = false)
      super || extension_for(method).present?
    end

    def attributes
      attributes_sets.to_value_object
    end

    # This will be overridden by the Persistence extension if a `:slug`
    # attribute is specified to the initialiser. Of course, since persisting an
    # entity is supposed to set the `slug` *field*, if the attribute is missing
    # the entity does not represent a persisted post. QED.
    def persisted?
      false
    end

    private

    attr_reader :attributes_sets, :original_attributes

    # Called from #init_attribute_mapping and from every optional extension,
    # such as Persistence.
    def add_attributes_set(set_index, values)
      attributes_sets[set_index] = values
    end

    # Helper for #method_missing.
    def ext_index_symbol_for(method_sym)
      extension_for(method_sym).to_s.split('::').last.downcase.to_sym
    end

    # The first half of #initialize. ONLY setter of instance variables!
    def init_attribute_mapping(attributes)
      @original_attributes = attributes
      @attributes_sets = AttributesSets.new
      add_attributes_set :core, CoreAttributes.new(attributes)
      @extension_mapper = AttributeExtensionMapper.new.build do |mapping|
        mapping[:core] = CoreAttributes.fields
      end
    end

    # The last half of #initialize.
    def load_extensions
      original_attributes.each_key do |k|
        extension = extension_for(k)
        next if [nil, :core].include?(extension)
        extend extension
      end
    end
  end # class Entity::Post
end
