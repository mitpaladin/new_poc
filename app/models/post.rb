
# A Post encapsulates an entry within a Blog.
class Post
  attr_accessor :blog, :body, :title

  def initialize(attrs = {})
    attrs.each do |k, v|
      ivar_sym = ['@', k].join.to_sym
      instance_variable_set ivar_sym, v if respond_to? k
    end
  end

  def publish
    blog.add_entry self
  end
end # class Blog::Post
