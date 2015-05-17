
require 'contracts'

require 'post'

# Class to create (and setup if needed) instance of DM entity for use cases.
class PostFactory
  class AttributeHash
    extend Forwardable
    include Contracts

    INIT_CONTRACT_INPUTS = Or[Hashlike, RespondTo[:attributes]]

    Contract INIT_CONTRACT_INPUTS => Hashlike
    def initialize(source)
      return @attributes = source if source.respond_to? :to_hash
      @attributes = source.attributes.symbolize_keys
    end

    def_delegators :@attributes, :to_hash, :to_h, :[]
  end
  private_constant :AttributeHash

  include Contracts
  class << self
    Contract AttributeHash::INIT_CONTRACT_INPUTS => Entity::Post
    def create(record)
      entity_class.new AttributeHash.new(record)
    end

    Contract None => Class
    def entity_class
      Entity::Post
    end
  end
end
