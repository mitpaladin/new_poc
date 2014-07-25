
# A Post encapsulates an entry within a Blog.
class Post
  # include ActiveAttr::BasicModel
  include Comparable
  attr_accessor :blog, :body, :title, :image_url, :pubdate
  attr_reader :author_name, :slug

  def initialize(attrs = {})
    attrs.each do |k, v|
      ivar_sym = ['@', k].join.to_sym
      instance_variable_set ivar_sym, v if respond_to? k
    end
  end

  def error_messages
    return [] if valid?
    BLO::PostDataBoundary.full_error_messages self
  end

  def publish(published_at = Time.now)
    blog.add_entry self
    @pubdate = published_at
  end

  def published?
    pubdate.present?
  end

  def valid?
    BLO::PostDataBoundary.valid? self
  end

  def <=>(other)
    parts = [
      [pubdate.to_i, other.pubdate.to_i],
      [title, other.title],
      [body, other.body],
      [image_url, other.image_url]
    ]
    checker = -> (part) { part[0] <=> part[1] }
    failed_parts = parts.reject { |part| checker.call(part) == 0 }
    return 0 if failed_parts.empty?
    checker.call failed_parts.first
  end
end # class Post
