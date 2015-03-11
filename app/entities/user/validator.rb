
require_relative 'internals/name_validator'

# Namespace containing all application-defined entities.
module Entity
  # The `User` class is the *core business-logic entity* modelling users in the
  # system. The core class encapsulates logic not specific to one use case or
  # group of use cases (such as authorisation). It also establishes a namespace
  # which encapsulates more specific entity-oriented responsibilities.
  class User
    # Validates attributes of a User class instance.
    class Validator
      extend Forwardable
      include ActiveModel::Validations

      def_delegators :@entity, :email, :name, :profile

      # NOTE: No uniqueness validation without database access.
      validates :name, presence: true, length: { minimum: 6 }
      validate :validate_name
      validates_email_format_of :email

      # Initialise a new `Entity::User::Validator` instance, specifying the
      # `Entity::User` instance whose attributes are to be validated.
      # @param entity [Entity::User] Instance to delegate attribute access to.
      def initialize(entity)
        @entity = entity
      end

      private

      # Validation method called by ActiveModel validation.
      # Instantiates internal object which validates name attribute and adds
      # ActiveModel errors if any validations fail.
      def validate_name
        Internals::NameValidator.new(name).validate.add_errors_to_model(self)
      end
    end # class Entity::User::Validator
  end # class Entity::User
end # module Entity
