
require_relative 'post/attribute_container'
require_relative 'post/title_validator'

# Namespace containing all application-defined entities.
module Entity
  # The Post class encapsulates post-related domain logic of our "fancy" blog.
  # It delegates or defers implementation-specific details such as persistence,
  # user interface, etc.
  class Post
    extend Forwardable

    def initialize(attributes_in)
      init_attributes attributes_in
      define_attribute_readers
      define_validators
    end

    def_delegator :@attributes, :attributes

    def errors
      validators[:title].errors
    end

    def valid?
      validators[:title].valid?
    end

    private

    attr_reader :validators

    def define_attribute_readers
      attributes.to_hash.each_key do |key|
        self.class.send :define_method, key do
          attributes.send key
        end
      end
    end

    def define_validators
      @validators = { title: TitleValidator.new(attributes) }
    end

    def init_attributes(attributes_in)
      attrs = AttributeContainer.new attributes_in
      whitelist = [:author_name, :title]
      @attributes = AttributeContainer.whitelist_from attrs, *whitelist
    end
  end # class Entity::Post
end
