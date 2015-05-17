
require 'contracts'

# Class to create (and setup if needed) instance of DM entity for use cases.
class UserFactory
  extend Forwardable
  include Contracts

  class << self
    INIT_CONTRACT_INPUTS = Or[Hashlike, RespondTo[:attributes]]

    Contract INIT_CONTRACT_INPUTS => Entity::User
    def create(record)
      entity_class.new record
    end

    Contract None => Class
    def entity_class
      Entity::User
    end

    delegate :guest_user, to: :entity_class
  end
end
