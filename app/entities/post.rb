
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
    class Attributes < ValueObject::Base
      has_fields :author_name, :body, :created_at, :image_url, :pubdate, :slug,
                 :title, :updated_at
    end
    private_constant :Attributes

    attr_reader :attributes
    def_delegators :@attributes, :author_name, :body, :created_at, :image_url,
                   :pubdate, :slug, :title, :updated_at

    def extend_with_presentation
      extend Extensions::Presentation
    end

    def extend_with_validation
      extend Extensions::Validation
    end

    def initialize(attributes)
      @attributes = Attributes.new attributes
    end

    def instance_variable_set(_symbol, _obj)
      fail "Can't touch this."
    end

    def persisted?
      slug.present?
    end

    # To implement an attribute setter, you'd do something like this. Note that
    # we *replace* the `@attributes` object with a new value object.
    # def author_name=(value)
    #   @attributes = attributes.copy_with(:author_name, value)
    # end
  end # class Entity::Post
end
