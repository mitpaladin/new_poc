
# A Post encapsulates an entry within a Blog.
class Post
  attr_accessor :blog, :body, :title

  def initialize(attrs = {})
    attrs.each { |k, v| send "#{k}=", v }
  end

  def publish
    blog.add_entry self
  end
end # class Blog::Post
