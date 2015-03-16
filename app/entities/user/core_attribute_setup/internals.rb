
# Namespace containing all application-defined entities.
module Entity
  # The `User` class is the *core business-logic entity* modelling users in the
  # system. The core class encapsulates logic not specific to one use case or
  # group of use cases (such as authorisation). It also establishes a namespace
  # which encapsulates more specific entity-oriented responsibilities.
  class User
    # Adds and initialises core attributes to User entity.
    class CoreAttributeSetup
      # Module to extend CoreAttributeSetup w/support methods for `.setup`.
      module Internals
        # Adds attribute readers for core attributes (:email, :name, :profile)
        # to instance of User entity.
        # @param entity Incoming entity instance to be manipulated.
        def define_attribute_readers(entity)
          entity.class_eval { attr_reader :email, :name, :profile }
        end

        # Adds `#attributes` and synonymous `#[]` instance methods to incoming
        # entity. They return a Hash of all instance variables on the entity,
        # keyed by variable name as a symbol.
        # @param entity Incoming entity instance to be manipulated.
        def define_methods(entity)
          entity.define_singleton_method :add_attribute do |attribute, value|
            class_eval { attr_reader attribute }
            instance_variable_set "@#{attribute}".to_sym, value
            @attribute_keys ||= []
            @attribute_keys.push attribute
            self
          end
          entity.define_singleton_method :attributes do
            instance_values.symbolize_keys.select do |key, _value|
              @attribute_keys.include? key
            end
          end
          entity.define_singleton_method :[] do |sym|
            attributes[sym]
          end
        end

        # Sets instance-variable values on the specified entity based on values
        # received in the `attributes` Hash.
        # @param entity Incoming entity instance to be manipulated;
        # @param attributes Named attribute values to use for initialisation.
        #                   Attributes supported directly by this class include:
        #
        #                   - `:name` -- uniquely identifies a specific user;
        #                   - `:email` -- valid email address for the user;
        #                   - `:profile` -- optional free-form personal biodata.
        #
        #                   Other attributes passed in `attributes` are ignored.
        def set_instance_variables(entity:, attributes:)
          items = [:email, :name, :profile]
          items.each { |item| entity.add_attribute item, attributes[item] }
        end
      end # module Entity::User::CoreAttributeSetup::Internals
    end # class Entity::User::CoreAttributeSetup
  end # class Entity::User
end
