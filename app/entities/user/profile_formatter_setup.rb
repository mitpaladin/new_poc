
require_relative 'profile_formatter_setup/internals'

# Namespace containing all application-defined entities.
module Entity
  # The `User` class is the *core business-logic entity* modelling users in the
  # system. The core class encapsulates logic not specific to one use case or
  # group of use cases (such as authorisation). It also establishes a namespace
  # which encapsulates more specific entity-oriented responsibilities.
  class User
    # Adds the `#formatted_profile` method and its supporting attribute to an
    # object instance (presumably of `Entity::User`).
    class ProfileFormatterSetup
      # Internal code used exclusively by `ProfileFormatterSetup`.
      module Internals
      end # module Entity::User::ProfileFormatterSetup::Internals
      private_constant :Internals
      extend Internals

      # Class method that creates a new attribute on an entity, setting it from
      # a value read from the incoming attributes. It then defines a method that
      # uses that attribute (presumably a Proc or lambda) to produce a value
      # based on a different attribute of the entity.
      # @param entity Incoming entity instance to be manipulated as described;
      # @param attributes A Hash-like object whose `:markdown_converter` entry
      #                   is used to initialise a new attribute on the entity.
      def self.setup(entity:, attributes:)
        entity.instance_variable_set :@markdown_converter,
                                     get_markdown_converter(attributes)
        entity.define_singleton_method :formatted_profile do
          @markdown_converter.call profile
        end
      end
    end # class Entity::User::ProfileFormatterSetup
  end # class Entity::User
end
