
require 'value_object'

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
      has_fields :author_name, :body, :created_at, :image_url, :pubdate, :slug,
                 :title, :updated_at
    end
    private_constant :CoreAttributes

    # attr_reader :attributes
    # def_delegators :@attributes, :author_name, :body, :created_at, :image_url,
    #                :pubdate, :slug, :title, :updated_at

    def extend_with_presentation
      extend Extensions::Presentation
    end

    def extend_with_validation
      extend Extensions::Validation
    end

    def initialize(attributes)
      @attributes = {}
      @attributes[:core] = CoreAttributes.new attributes
    end

    def instance_variable_set(_symbol, _obj)
      fail "Can't touch this."
    end

    def method_missing(method_sym, *arguments, &block)
      attribs = attributes
      return super unless attribs.respond_to?(method_sym)
      # We're asking for an attribute; let's define a reader for it so we
      # don't come here again looking for that attribute
      define_singleton_method method_sym do
        attributes.send method_sym
      end
      send method_sym
    end

    def respond_to?(method, include_private = false)
      super || attributes.fields.include?(method)
    end

    def attributes
      all_attributes = collect_attributes
      # OK; we've a *Hash* of every attribute in the entity; but what we really
      # want is a *ValueObject*.
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
  end # class Entity::Post
end
