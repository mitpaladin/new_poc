
require 'active_model'
require 'instance_variable_setter'

require_relative 'user_entity/name_validator'

# Persistence entity-layer representation for User. Not a domain object; used to
# communicate across the repository/DAO boundary.
class UserEntity
  include ActiveAttr::BasicModel
  include ActiveAttr::Serialization
  include Comparable

  # Internal, private support classes for UserEntity
  module Internals
  end # module UserEntity::Internals
  private_constant :Internals

  attr_reader :email,
              :name,
              :password,
              :password_confirmation,
              :profile,
              :slug,
              :created_at,
              :updated_at

  # NOTE: No `uniqueness: true` without database access...
  validates :name, presence: true, length: { minimum: 6 }
  validate :validate_name
  validates_email_format_of :email
  validate :passwords_are_valid

  def initialize(attribs)
    init_attrib_keys.each { |attrib| class_eval { attr_reader attrib } }
    InstanceVariableSetter.new(self).set attribs
  end

  def attributes
    instance_values.symbolize_keys
  end

  def formatted_profile
    MarkdownHtmlConverter.new.to_html profile
  end

  def guest_user?
    slug == guest_user_entity.slug
  end

  # callback used by InstanceVariableSetter
  def init_attrib_keys
    %w(created_at email name password password_confirmation profile slug
       updated_at).map(&:to_sym)
  end

  # we're using FriendlyID for slugs, so...
  def persisted?
    !slug.nil?
  end

  def registered?
    !guest_user?
  end

  def <=>(other)
    name <=> other.name
  end

  private

  # FIXME: Wrong-way dependency; better way to fix?
  def guest_user_entity
    UserRepository.new.guest_user.entity
  end

  def validate_name
    Internals::NameValidator.new(name)
      .validate
      .add_errors_to_model(self)
  end

  def passwords_match?
    password.to_s.strip.present? &&
      (password == password.to_s.strip) &&
      (password == password_confirmation)
  end

  def passwords_omitted?
    password.to_s.strip.empty? && password_confirmation.to_s.strip.empty?
  end

  def passwords_are_valid
    return if passwords_omitted? || passwords_match?
    errors.add :password, 'must match the password confirmation'
  end
end # class UserEntity
