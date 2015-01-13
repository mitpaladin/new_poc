
require 'active_model'
require 'instance_variable_setter'

require 'newpoc/services/markdown_html_converter'

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
              :profile,
              :slug,
              :created_at,
              :updated_at

  # NOTE: No `uniqueness: true` without database access...
  validates :name, presence: true, length: { minimum: 6 }
  validate :validate_name
  validates_email_format_of :email

  def initialize(attribs)
    init_attrib_keys.each do |key|
      instance_variable_set "@#{key}".to_sym, attribs[key.to_s]
    end
    # MainLogger.log.debug [:user_entity_41, name, email, profile]
    InstanceVariableSetter.new(self).set attribs
  end

  def attributes
    instance_values.symbolize_keys
  end

  def formatted_profile
    Newpoc::Services::MarkdownHtmlConverter.new.to_html profile
  end

  def guest_user?
    slug == guest_user_entity.slug
  end

  # callback used by InstanceVariableSetter
  def init_attrib_keys
    %w(created_at email name profile slug updated_at).map(&:to_sym)
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
end # class UserEntity
