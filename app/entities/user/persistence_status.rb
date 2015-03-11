
# Namespace containing all application-defined entities.
module Entity
  # The `User` class is the *core business-logic entity* modelling users in the
  # system. The core class encapsulates logic not specific to one use case or
  # group of use cases (such as authorisation). It also establishes a namespace
  # which encapsulates more specific entity-oriented responsibilities.
  class User
    # Class encapsulates persistence-status flag and "slug" attribute.
    class PersistenceStatus
      # The `slug` attribute is used as the unique identifier for an entity
      # instance. It is normally a variant of the user name which does not
      # contain any whitespace, but this class knows or enforces none of that.
      attr_reader :slug

      # Initialise a new `Entity::User::PersistenceStatus` instance based on the
      # attributes passed in.
      # @param attributes Named attribute values to use for initialisation.
      #                   The only attribute supported directly by this class is
      #
      #                   - `:slug` -- uniquely identifies a specific user.
      #
      #                   Other attributes passed in are ignored.
      def initialize(attributes)
        @slug = attributes[:slug]
      end

      # If the `slug` attribute exists, the containing entity is assumed to have
      # been persisted to some form of storage.
      # @return boolean Returns true if the `slug` is present; false otherwise.
      def persisted?
        @slug.present?
      end
    end # class Entity::User::PersistenceStatus
  end # class Entity::User
end # module Entity
