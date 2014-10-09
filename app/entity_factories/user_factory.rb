
require_relative '../entities/user_entity'

# Class to create (and setup if needed) instance of DM entity for use cases.
class UserFactory
  class << self
    def create(record)
      UserEntity.new record
    end
  end
end
