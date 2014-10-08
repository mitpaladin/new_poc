
require 'active_model'

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
    attribs.each do |k, v|
      instance_variable_set "@#{k}".to_sym, v if can_initialise? k
    end
  end

  def attributes
    instance_values.symbolize_keys
  end

  # we're using FriendlyID for slugs, so...
  def persisted?
    !slug.nil?
  end

  private

  def can_initialise?(key)
    %w(created_at email name password password_confirmation profile slug
       updated_at).map(&:to_sym).include? key
  end
end # class UserEntity
