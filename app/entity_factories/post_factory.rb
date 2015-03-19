
require 'newpoc/entity/post'

# Class to create (and setup if needed) instance of DM entity for use cases.
class PostFactory
  class << self
    def create(record)
      entity_class.new record
    end

    def entity_class
      Newpoc::Entity::Post
    end
  end
end
