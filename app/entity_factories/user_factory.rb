
require 'newpoc/entity/user'

# Class to create (and setup if needed) instance of DM entity for use cases.
class UserFactory
  class << self
    def create(record)
      Newpoc::Entity::User.new record
    end
  end
end
