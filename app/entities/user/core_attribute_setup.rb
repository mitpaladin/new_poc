
require_relative 'core_attribute_setup/internals'

# Namespace containing all application-defined entities.
module Entity
  # FIXME: Contracts?
  # The `User` class is the *core business-logic entity* modelling users in the
  # system. The core class encapsulates logic not specific to one use case or
  # group of use cases (such as authorisation). It also establishes a namespace
  # which encapsulates more specific entity-oriented responsibilities.
  class User
    # Adds and initialises core attributes to User entity.
    class CoreAttributeSetup
      # Module to extend CoreAttributeSetup w/support methods for `.setup`.
      module Internals
      end
      private_constant :Internals
      extend Internals

      # Initialises values of, and defines read-only accessors for, "core"
      # attributes of a User entity.
      # @param entity Incoming entity instance to be manipulated as described;
      # @param attributes Named attribute values to use for initialisation.
      def self.setup(entity:, attributes:)
        define_methods(entity)
        define_attribute_readers(entity)
        set_instance_variables entity: entity, attributes: attributes
      end
    end # class Entity::User::CoreAttributeSetup
  end # class Entity::User
end
