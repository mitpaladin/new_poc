
require 'active_model'
require 'active_support/core_ext'
require 'validates_email_format_of'

require 'newpoc/entity/user/version'
require 'newpoc/entity/user/name_validator'

# FIXME: Periodically try disabling this after updating to new release of
#        ActiveModel and see if they've fixed the conflict w/stdlib Forwardable.
#        This is per https://github.com/cequel/cequel/issues/193 - another epic
#        ActiveFail.
module Forwardable
  remove_method :delegate
end

module Newpoc
  module Entity
    # Domain entity for a user of the system.
    class User
      extend Forwardable
      include ActiveModel::Validations

      # Internal, private support classes for UserEntity
      module Internals
      end # module UserEntity::Internals
      private_constant :Internals

      attr_reader :email,
                  :name,
                  :profile,
                  :slug,
                  :created_at,
                  :updated_at

      def_delegator :attributes, :[]

      # NOTE: No `uniqueness: true` without database access...
      validates :name, presence: true, length: { minimum: 6 }
      validate :validate_name
      validates_email_format_of :email

      def initialize(attribs)
        @name = attribs[:name]
        @email = attribs[:email]
        @slug = attribs[:slug]
        @updated_at = attribs[:updated_at]
        @profile = attribs.fetch :profile, ''
        @created_at = attribs.fetch :created_at, Time.now
      end

      def attributes
        instance_values.symbolize_keys
      end

      def guest_user?
        name == self.class.guest_user.name
      end

      def persisted?
        !slug.to_s.empty?
      end

      class << self
        def guest_user
          profile = 'No user is presently logged in. I was *never* here.'
          User.new name: 'Guest User', email: 'guest@example.com',
                   profile: profile
        end
      end

      private

      def validate_name
        Internals::NameValidator.new(name)
          .validate
          .add_errors_to_model(self)
      end
    end # class Newpoc::Entity::User
  end
end
