
require 'active_model'
require 'instance_variable_setter'

# Persistence entity-layer representation for User. Not a domain object; used to
# communicate across the repository/DAO boundary.
class UserEntity
  include ActiveAttr::BasicModel
  include ActiveAttr::Serialization
  include Comparable

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
  validate :name_has_no_spaces_at_ends
  validate :name_has_no_adjacent_whitespace
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

  # Because there's no guarantee that the presence validation will be first.
  # def name_is_missing_or_blank
  #   errors.add :name, 'may not be missing or blank'
  # end

  def name_has_no_adjacent_whitespace
    # return name_is_missing_or_blank unless name.to_s.strip.present?
    return if name.to_s.strip == name.to_s.strip.gsub(/\s{2,}/, '?')
    errors.add :name, 'may not have adjacent whitespace'
  end

  def name_has_no_invalid_whitespace
    # return name_is_missing_or_blank unless name.to_s.strip.present?
    expected = name.strip.gsub(/ {2,}/, ' ')
    return if expected == expected.gsub(/\s/, ' ')
    errors.add :name, 'may not have whitespace other than spaces'
  end

  def name_has_no_spaces_at_ends # rubocop:disable Metrics/AbcSize
    # return name_is_missing_or_blank unless name.to_s.strip.present?
    return if name.to_s == name.to_s.strip
    message = 'may not have leading whitespace'
    errors.add :name, message if name != name.lstrip
    message = 'may not have trailing whitespace'
    errors.add :name, message if name != name.rstrip
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
