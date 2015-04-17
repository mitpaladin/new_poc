
require_relative 'post/attribute_container'
require_relative 'post/validator_grouping'

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
      @validators = ValidatorGrouping.new attributes_in
    end

    def_delegator :@attributes, :attributes
    def_delegators :@validators, :errors, :valid?

    private

    def define_attribute_readers
      attributes.to_hash.each_key do |key|
        class_eval { def_delegator :attributes, key }
      end
    end

    def init_attributes(attributes_in)
      attrs = AttributeContainer.new attributes_in
      whitelist = [
        # core attributes
        :author_name, :body, :image_url, :title,
        # publication attributes
        :pubdate, :slug,
        # persistence attributes
        :created_at, :updated_at]
      @attributes = AttributeContainer.whitelist_from attrs, *whitelist
    end
  end # class Entity::Post
end
