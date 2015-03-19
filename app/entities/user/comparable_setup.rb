
# Namespace containing all application-defined entities.
module Entity
  # The `User` class is the *core business-logic entity* modelling users in the
  # system. The core class encapsulates logic not specific to one use case or
  # group of use cases (such as authorisation). It also establishes a namespace
  # which encapsulates more specific entity-oriented responsibilities.
  class User
    # Add comparison support to entity.
    class ComparableSetup
      # Add comparison support to entity, by including `Comparable` in its
      # singleton class and defining the comparison-operator method on the
      # entity.
      # @param entity Incoming entity instance to be manipulated as described;
      def self.setup(entity)
        entity.class_eval { include Comparable }
        entity.define_singleton_method :<=> do |other|
          name <=> other.name
        end
      end
    end # class Entity::User::ComparableSetup
  end # class Entity::User
end
