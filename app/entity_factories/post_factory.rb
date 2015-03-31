
require 'post'

# Class to create (and setup if needed) instance of DM entity for use cases.
class PostFactory
  class << self
    def create(record)
      entity_class.new record.attributes.symbolize_keys
    end

    def entity_class
      Entity::Post
    end
  end
end
