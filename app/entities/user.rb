
# Namespace containing all application-defined entities.
module Entity
  # The `User` class is the *core business-logic entity* modelling users in the
  # system. The core class encapsulates logic not specific to one use case or
  # group of use cases (such as authorisation). It also establishes a namespace
  # which encapsulates more specific entity-oriented responsibilities.
  class User
    extend Forwardable

    def_delegator :attributes, :[]

    attr_reader :email, :name, :profile

    # Initialise a new `Entity::User` instance, optionally specifying values for
    # setting attributes.
    # @param attributes Named attribute values to use for initialisation.
    #                   Attributes supported directly by this class include:
    #
    #                   - `:name` -- uniquely identifies a specific user;
    #                   - `:email` -- valid email address for the user;
    #                   - `:profile` -- optional free-form personal description.
    #
    #                   Other attributes passed to `#initialize` are passed to
    #                   encapsulated classes' initialisers (if any) or ignored.
    def initialize(attributes = {})
      @name = attributes[:name]
      @email = attributes[:email]
      @profile = attributes[:profile]
    end

    # Returns a Hash containing this instance's attribute values.
    # @return Hash Attributes (:name, :email, :profile) with values, in a Hash.
    def attributes
      instance_values.symbolize_keys
    end
  end # class Entity::User
end
