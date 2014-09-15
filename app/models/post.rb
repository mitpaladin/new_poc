
# A Post encapsulates an entry within a Blog.
class Post
  # include ActiveAttr::BasicModel
  include Comparable
  attr_accessor :blog, :body, :title, :image_url, :pubdate, :created_at
  attr_reader :author_name, :slug

  def initialize(attrs = {})
    attrs.each do |k, v|
      ivar_sym = ['@', k].join.to_sym
      instance_variable_set ivar_sym, v if respond_to? k
    end
  end

  def error_messages
    validator = PostUpdateValidator.new self
    return [] if validator.valid?
    validator.messages.values
  end

  def publish(published_at = Time.now)
    blog.add_entry self
    @pubdate = published_at
  end

  def published?
    pubdate.present?
  end

  def to_h
    {
      author_name:  author_name,
      body:         body,
      created_at:   created_at,
      image_url:    image_url,
      pubdate:      pubdate,
      slug:         slug,
      title:        title
    }
  end

  def valid?
    PostUpdateValidator.new(self).valid?
  end

  def <=>(other)
    parts = comparison_order(other)
    checker = -> (part) { part[0] <=> part[1] }
    failed_parts = parts.reject { |part| checker.call(part) == 0 }
    return 0 if failed_parts.empty?
    checker.call failed_parts.first
  end

  private

  def comparison_order(other)
    [
      [pubdate.to_i, other.pubdate.to_i],
      [created_at.to_i, other.created_at.to_i],
      [title, other.title],
      [body, other.body],
      [image_url, other.image_url]
    ]
  end
end # class Post
