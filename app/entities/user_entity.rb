
require 'active_model'
require 'instance_variable_setter'

# Persistence entity-layer representation for User. Not a domain object; used to
# communicate across the repository/DAO boundary.
class UserEntity
  include ActiveModel::Serializers::JSON

  attr_reader :email,
              :name,
              :password,
              :password_confirmation,
              :profile,
              :slug,
              :created_at,
              :updated_at

  def initialize(attribs)
    init_attrib_keys.each { |attrib| class_eval { attr_reader attrib } }
    InstanceVariableSetter.new(self).set attribs
  end

  def attributes
    instance_values.symbolize_keys
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

  def inspect
    [self.class.name, 'with attributes', attributes.to_s].join ' '
  end
end # class UserEntity
