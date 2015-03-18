
require_relative 'user_factory'

# Class to create instance of entities with passwords for use cases.
class UserPasswordEntityFactory
  module Internals
    # Encapsulate password and confirmation string; latter defaults to former.
    class PasswordPair
      attr_reader :password, :confirmation

      def initialize(password:, confirmation: nil)
        @password = password
        @confirmation = confirmation || password
      end
    end

    def add_attribute_writers(entity)
      # Password entities aren't like usual entities; need to be assignable.
      entity.class_eval { attr_accessor :password, :password_confirmation }
    end

    def build_passwords(attributes:, password:)
      confirmation = attributes[:password_confirmation]
      password ||= attributes[:password]
      PasswordPair.new password: password, confirmation: confirmation
    end

    def add_validations(entity)
      entity.class_eval do
        include ActiveModel::Validations
        validates :password, confirmation: true
      end
    end
  end
  private_constant :Internals
  extend Internals

  def self.create(attribs_in, password = nil)
    attribs = attribs_in.symbolize_keys
    entity = UserFactory.create attribs
    passwords = build_passwords attributes: attribs, password: password
    entity.add_attribute :password, passwords.password
    add_attribute_writers entity
    add_validations entity
    entity.password_confirmation = passwords.confirmation
    entity
  end
end
