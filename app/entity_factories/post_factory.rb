
require 'newpoc/entity/post'
# require 'post'

# Class to create (and setup if needed) instance of DM entity for use cases.
class PostFactory
  class AttributeHash
    extend Forwardable

    def initialize(source)
      return @attributes = source if source.respond_to? :to_hash
      @attributes = source.attributes.symbolize_keys
    end

    def_delegators :@attributes, :to_hash, :to_h, :[]
  end
  private_constant :AttributeHash

  class << self
    def create(record)
      entity_class.new AttributeHash.new(record)
    end

    def entity_class
      Newpoc::Entity::Post
      # Entity::Post
    end
  end
end
