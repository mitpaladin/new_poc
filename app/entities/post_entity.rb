
require 'active_model'
require 'instance_variable_setter'

require_relative 'post_entity/byline_builder'
require_relative 'post_entity/image_body_builder'
require_relative 'post_entity/text_body_builder'
require_relative 'post_entity/timestamp_builder'

# Persistence entity-layer representation for Post. Not a domain object; used to
# communicate across the repository/DAO boundary.
class PostEntity
  include ActiveAttr::BasicModel
  include ActiveAttr::Serialization

  validates :author_name, presence: true
  validates :title, presence: true
  validate :must_have_body_or_title
  validate :author_must_be_a_registered_user

  def initialize(attribs)
    init_attrib_keys.each { |attrib| class_eval { attr_reader attrib } }
    InstanceVariableSetter.new(self).set attribs
    @pubdate ||= Time.now if attribs[:post_status] == 'public'
    extend EntityShared
  end

  def attributes
    instance_values.symbolize_keys
  end

  # After Avdi's #render_body; his "exhibits" are much more closely associated
  # with views than Draper's decorators are. While that's a perfectly valid
  # choice, especially the way he abstracts it, I've chosen differently. Since
  # the question "is this an image post or a text post" is answered purely by
  # consulting the contents of the *model*, it seems to me entirely natural to
  # add the outcome of that question to something closely associated with, but
  # not strictly part of, the model. Doing so obviates the entire question of
  # view partial templates, replacing them with "pure Ruby" code.
  def build_body
    fragment = body_builder_class.new.build self
    convert_body fragment
  end

  def build_byline
    BylineBuilder.new(self).to_html
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

  def pubdate_str
    return 'DRAFT' if draft?
    timestamp_for pubdate
  end

  def published?
    pubdate.present?
  end

  def draft?
    pubdate.nil?
  end

  def post_status
    published? ? 'public' : 'draft'
  end

  private

  def guest_user_name
    'Guest User'
  end

  def author_must_be_a_registered_user
    return unless author_name == guest_user_name
    errors.add :author_name, 'must be a registered user'
  end

  def body_builder_class
    if image_url.present?
      SupportClasses::ImageBodyBuilder
    else
      SupportClasses::TextBodyBuilder
    end
  end

  def convert_body(fragment)
    MarkdownHtmlConverter.new.to_html(fragment)
  end

  def must_have_body_or_title
    return if body.present? || image_url.present?
    errors.add :body, 'must be specified if image URL is omitted'
  end

  def timestamp_for(the_time = Time.now)
    the_time.to_time.localtime.strftime timestamp_format
  end

  def timestamp_format
    '%a %b %e %Y at %R %Z (%z)'
  end
end # class PostEntity
