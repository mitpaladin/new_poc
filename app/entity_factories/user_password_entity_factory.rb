
require_relative 'user_factory'

# Class to create instance of entities with passwords for use cases.
class UserPasswordEntityFactory
  # Internal to containing class only; hidden from outside world.
  module Internals
    def add_passwords(entity:, attributes:, password:)
      password ||= attributes[:password]
      confirmation = attributes[:password_confirmation] || password
      entity.add_attribute :password, password
      entity.add_attribute :password_confirmation, confirmation
    end

    def add_validation_method(entity)
      existing = entity.method :valid? if entity.methods.include?(:valid?)
      entity.instance_variable_set :@existing_valid, existing
      entity.define_singleton_method :valid? do
        return false if password != password_confirmation
        return false if password.to_s.length < 6
        return true unless @existing_valid
        @existing_valid.call
      end
    end
  end
  private_constant :Internals
  extend Internals

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
end
