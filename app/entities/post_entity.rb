
require 'active_model'

# Persistence entity-layer representation for Post. Not a domain object; used to
# communicate across the repository/DAO boundary.
class PostEntity
  include ActiveModel::Serializers::JSON

  attr_reader :author_name,
              :body,
              :image_url,
              :slug,
              :title,
              :pubdate,
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
    %w(author_name body image_url slug title pubdate created_at updated_at)
        .map(&:to_sym).include? key
  end
end # class PostEntity
