
require 'active_model'
require 'instance_variable_setter'

# Persistence entity-layer representation for Post. Not a domain object; used to
# communicate across the repository/DAO boundary.
class PostEntity
  include ActiveModel::Serializers::JSON

  def initialize(attribs)
    init_attrib_keys.each { |attrib| class_eval { attr_reader attrib } }
    InstanceVariableSetter.new(self).set attribs
  end

  def attributes
    instance_values.symbolize_keys
  end

  # callback used by InstanceVariableSetter
  def init_attrib_keys
    %w(author_name body image_url slug title pubdate created_at updated_at)
        .map(&:to_sym)
  end

  # we're using FriendlyID for slugs, so...
  def persisted?
    !slug.nil?
  end
end # class PostEntity
