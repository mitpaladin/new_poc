
require 'newpoc/entity/user'

# Class to create (and setup if needed) instance of DM entity for use cases.
class UserFactory
  class << self
    def create(record)
      entity_class.new record
    end

    def entity_class
      Newpoc::Entity::User
    end
  end
end
