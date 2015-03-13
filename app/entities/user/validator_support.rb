
require_relative 'validator_support/internals/name_validator'

# Namespace containing all application-defined entities.
module Entity
  # The `User` class is the *core business-logic entity* modelling users in the
  # system. The core class encapsulates logic not specific to one use case or
  # group of use cases (such as authorisation). It also establishes a namespace
  # which encapsulates more specific entity-oriented responsibilities.
  class User
    # Class responsible for adding field validation to a User entity.
    class ValidatorSupport
      module Internals
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
          # @param entity [Entity::User] Instance to delegate attribute access
          # to.
          def initialize(entity)
            @entity = entity
          end

          private

          # Validation method called by ActiveModel validation.
          # Instantiates internal object which validates name attribute and adds
          # ActiveModel errors if any validations fail.
          def validate_name
            NameValidator.new(name)
              .validate
              .add_errors_to_model(self)
          end
        end # class Entity::User::ValidatorSupport::Internals::Validator
      end
      private_constant :Internals
      include Internals

      # Sets up validation for the passed-in entity by instantiating a Validator
      # and adding it as an instance variable to the passed-in entity. This
      # keeps the validation linkage alive for the lifetime of the underlying
      # (now containing) entity.
      #
      # This is *all kinds of fail*. Prior to Rails 4.2, I'd been able to just
      # drop `ActiveModel::Validations` into J Random Object and have it Just
      # Work (with the addition of a `.model_name` class method as well). Those
      # halcyon days are apparently *over*, as 4.2 plays mind games with hooking
      # into larger pieces of ActiveModel/Rails, e.g., i18n. Not happy.
      #
      # Why does this particularly suck? Because now I have to add an *instance
      # variable* to the underlying entity, instead of just using standard Ruby
      # metaprogramming to have my way with including modules, adding
      # validations, and such. I've long felt that adding state to an object
      # (which is what instance variables *are*) is inferior to modifying its
      # logic via `extend` and other bits of Ruby inheritance/metaprogramming.
      def self.setup(entity)
        validator = Validator.new entity
        entity.instance_variable_set :@validator, validator
      end
    end # class ValidatorSupport
  end # class Entity::User
end # module Entity
