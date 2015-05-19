
require_relative '../user_factory'

# Class to create (and setup if needed) instance of DM entity for use cases.
class UserFactory
  # Class to create instance of entities with passwords for use cases.
  class WithPassword
    include Contracts

    # Internal to containing class only; hidden from outside world.
    module Internals
      include Contracts

      AP_INPUT_CONTRACT = {
        entity: Entity::User,
        attributes: HashOf[Symbol, Any],
        password: Maybe[String] # See Issue #276
      }

      Contract AP_INPUT_CONTRACT => Any # UserFactory::WithPassword
      def add_passwords(entity:, attributes:, password:)
        password ||= attributes[:password]
        confirmation = attributes[:password_confirmation] || password
        entity.add_attribute :password, password
        entity.add_attribute :password_confirmation, confirmation
        self
      end

      Contract Entity::User => Any # UserFactory::WithPassword
      def add_validation_method(entity)
        existing = entity.method :valid? if entity.methods.include?(:valid?)
        entity.instance_variable_set :@existing_valid, existing
        entity.define_singleton_method :valid? do
          return false if password != password_confirmation
          return false if password.to_s.length < 6
          return true unless @existing_valid
          @existing_valid.call
        end
        self
      end
    end
    private_constant :Internals
    extend Internals

    Contract Hashlike, Maybe[String] => Entity::User
    def self.create(attribs_in, password = nil)
      attribs = attribs_in.symbolize_keys
      entity = UserFactory.create attribs
      add_passwords entity: entity, attributes: attribs, password: password
      # Password entities aren't like usual entities; need to be assignable.
      entity.class_eval { attr_accessor :password, :password_confirmation }
      entity.class_eval { include ActiveModel::Validations }
      add_validation_method entity
      entity
    end
  end # class UserFactory::WithPassword
end # class UserFactory
