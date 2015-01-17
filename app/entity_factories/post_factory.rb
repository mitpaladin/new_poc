
require 'newpoc/entity/post'

# Class to create (and setup if needed) instance of DM entity for use cases.
class PostFactory
  class << self
    def create(record)
      Newpoc::Entity::Post.new record
    end
  end
end
