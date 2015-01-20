
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
      include Comparable
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
        @markdown_converter = attribs[:markdown_converter] ||
                              default_markdown_converter
        @name = attribs[:name]
        @email = attribs[:email]
        @slug = attribs[:slug]
        @updated_at = attribs[:updated_at]
        @profile = attribs[:profile] || ''
        @created_at = attribs[:created_at] || Time.now
      end

      def attributes
        ret = instance_values.symbolize_keys
        ret.reject { |k, _v| k.to_s.match(/.*markdown_converter.*/) }
      end

      def formatted_profile
        markdown_converter.call profile
      end

      def guest_user?
        name == self.class.guest_user.name
      end

      def persisted?
        !slug.to_s.empty?
      end

      def <=>(other)
        name <=> other.name
      end

      class << self
        def guest_user
          profile = 'No user is presently logged in. I was *never* here.'
          User.new name: 'Guest User', email: 'guest@example.com',
                   profile: profile
        end
      end

      # FIXME: Holdover for entity-factory specs. Fixme applies to those specs.
      def init_attrib_keys
        %w(created_at email name profile slug updated_at).map(&:to_sym)
      end

      private

      attr_reader :markdown_converter

      def default_markdown_converter
        # This method's body *WILL NOT* be shown as "covered" in unit-test specs
        # since this depends on code which is unavailable (and substituted for)
        # in that context. It *should* be covered in main-app feature specs.
        lambda do |markup|
          require 'newpoc/services/markdown_html_converter'
          Newpoc::Services::MarkdownHtmlConverter.new.to_html markup
        end
      end

      def validate_name
        Internals::NameValidator.new(name)
          .validate
          .add_errors_to_model(self)
      end
    end # class Newpoc::Entity::User
  end
end
