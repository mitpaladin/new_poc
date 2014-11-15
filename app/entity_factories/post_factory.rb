
require_relative '../entities/post_entity'

# Class to create (and setup if needed) instance of DM entity for use cases.
class PostFactory
  class << self
    def create(record)
      PostEntity.new record
    end
  end
end
