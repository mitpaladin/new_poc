
require_relative 'user/guest_user'
require_relative 'user/persistence_status'
require_relative 'user/validator'

# Namespace containing all application-defined entities.
module Entity
  # The `User` class is the *core business-logic entity* modelling users in the
  # system. The core class encapsulates logic not specific to one use case or
  # group of use cases (such as authorisation). It also establishes a namespace
  # which encapsulates more specific entity-oriented responsibilities.
  class User
    extend Forwardable

    # `some_obj[:foo]` is an alias for `some_obj.attributes[:foo]`
    def_delegator :attributes, :[]
    # Validate core attributes
    def_delegators :@validator, :valid?, :invalid?
    # Delegate knowledge of persistence-status determination
    def_delegators :@persistence_status, :persisted?, :slug

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
      @persistence_status = PersistenceStatus.new attributes
      @validator = Validator.new self
    end

    # Returns a Hash containing this instance's attribute values.
    # @return Hash Attributes (:name, :email, :profile) with values, in a Hash.
    def attributes
      instance_values.symbolize_keys
    end
  end # class Entity::User
end
