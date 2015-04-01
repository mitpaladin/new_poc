
require 'post'

# Class to create (and setup if needed) instance of DM entity for use cases.
class PostFactory
  module Internals
    def as_hash(record)
      h = record.respond_to?(:attributes) ? record.attributes : record
      h.to_hash.symbolize_keys
    end
  end # module PostFactory::Internals
  private_constant :Internals
  extend Internals

  class << self
    def create(record)
      entity_class.new as_hash(record)
    end

    def entity_class
      Entity::Post
    end
  end
end
