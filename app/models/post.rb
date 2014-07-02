
# A Post encapsulates an entry within a Blog.
class Post
  # include ActiveAttr::BasicModel
  attr_accessor :blog, :body, :title, :image_url, :pubdate
  attr_reader :published
  alias_method :published?, :published

  def initialize(attrs = {})
    attrs.each do |k, v|
      ivar_sym = ['@', k].join.to_sym
      instance_variable_set ivar_sym, v if respond_to? k
    end
    @published = false
  end

  def error_messages
    return [] if valid?
    BLO::PostDataBoundary.full_error_messages self
  end

  def publish
    blog.add_entry self
    @published = true
  end

  def valid?
    BLO::PostDataBoundary.valid? self
  end
end # class Post
