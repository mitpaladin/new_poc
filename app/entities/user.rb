
require_relative 'user/comparable_setup'
require_relative 'user/core_attribute_setup'
require_relative 'user/guest_user'
require_relative 'user/persistence_setup'
require_relative 'user/profile_formatter_setup'
require_relative 'user/timestamp_setup'
require_relative 'user/validator_support'

# Namespace containing all application-defined entities.
module Entity
  # The `User` class is the *core business-logic entity* modelling users in the
  # system. The core class encapsulates logic not specific to one use case or
  # group of use cases (such as authorisation). It also establishes a namespace
  # which encapsulates more specific entity-oriented responsibilities.
  class User
    # Initialise a new `Entity::User` instance, optionally specifying values for
    # setting attributes.
    # @param attributes Named attribute values to use for initialisation.
    def initialize(attributes = {})
      CoreAttributeSetup.setup entity: self, attributes: attributes
      PersistenceSetup.setup entity: self, attributes: attributes
      ProfileFormatterSetup.setup entity: self, attributes: attributes
      TimestampSetup.setup entity: self, attributes: attributes
      ValidatorSupport.setup self
      ComparableSetup.setup self
    end

    # Help ActiveModel separate its oesophagus from its tailpipe.
    # FIXME: Move to module?
    def model_name
      ActiveModel::Name.new self, nil, 'User'
    end
  end # class Entity::User
end
