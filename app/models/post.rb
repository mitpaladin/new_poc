
# A Post encapsulates an entry within a Blog.
class Post
  # include ActiveAttr::BasicModel
  attr_accessor :blog, :body, :title, :image_url, :pubdate

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
end # class Post
