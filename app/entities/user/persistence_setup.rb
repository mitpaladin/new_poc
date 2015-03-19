
# Namespace containing all application-defined entities.
module Entity
  # The `User` class is the *core business-logic entity* modelling users in the
  # system. The core class encapsulates logic not specific to one use case or
  # group of use cases (such as authorisation). It also establishes a namespace
  # which encapsulates more specific entity-oriented responsibilities.
  class User
    # Adds persistence-status-related attribute/method to entity instance.
    class PersistenceSetup
      # Adds a `slug` instance variable and attribute reader to the passed-in
      # entity, then adds a `:persisted?` method to the entity that returns a
      # Boolean based on that `slug` attribute value.
      # @param entity Incoming entity instance to be manipulated;
      # @param attributes Named attribute values from which to retrieve the
      #                   `:slug` value.
      def self.setup(entity:, attributes:)
        entity.add_attribute :slug, attributes[:slug]
        entity.define_singleton_method :persisted? do
          slug.present?
        end
      end
    end # class Entity::User::PersistenceSetup
  end # class Entity::User
end
