
# A Post encapsulates an entry within a Blog.
class Post
  # include ActiveAttr::BasicModel
  attr_accessor :blog, :body, :title, :image_url
  attr_reader :published
  alias_method :published?, :published

  def initialize(attrs = {})
    attrs.each do |k, v|
      ivar_sym = ['@', k].join.to_sym
      instance_variable_set ivar_sym, v if respond_to? k
    end
    @published = false
  end

  def publish
    blog.add_entry self
    @published = true
  end

  def valid?
    # BLO::PostDataBoundary.valid? self
    String(title).present?
  end
end # class Post
