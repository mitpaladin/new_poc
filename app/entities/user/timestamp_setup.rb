
require 'contracts'

# Namespace containing all application-defined entities.
module Entity
  # The `User` class is the *core business-logic entity* modelling users in the
  # system. The core class encapsulates logic not specific to one use case or
  # group of use cases (such as authorisation). It also establishes a namespace
  # which encapsulates more specific entity-oriented responsibilities.
  class User
    # Adds timestamp attributes and attribute-reader methods to an entity.
    class TimestampSetup
      include Contracts

      SETUP_CONTRACT_INPUTS = {
        entity: Entity::User,
        attributes: RespondTo[:[]]
      }

      # Adds the `#created_at` and `#updated_at` attribute readers to the entity
      # and sets matching instance variables based on the incoming attributes.
      # @param entity Incoming entity instance to be manipulated;
      # @param attributes A Hash-like object whose `:created_at` and
      #                   `:updated_at` entires are used to initialise new
      #                   attributes on the entity. If no value is supplied for
      #                   `:created_at`, the current time (as UTC) will be used.
      Contract SETUP_CONTRACT_INPUTS => Entity::User
      def self.setup(entity:, attributes:)
        created_at = attributes[:created_at] || Time.zone.now
        entity.add_attribute :created_at, created_at
        entity.add_attribute :updated_at, attributes[:updated_at]
        entity
      end
    end # class Entity::User::TimestampSetup
  end # class ENtity::User
end
