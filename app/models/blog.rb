
include Forwardable

# Blog class encapsulates the blog as a whole.
class Blog
  extend Forwardable
  def_delegators :@blog_data, :title, :subtitle
  attr_writer :post_source

  def initialize
    @blog_data = BlogDataBoundary.new
  end

  def add_entry(entry)
    PostDataBoundary.save_entry entry
  end

  def entries
    PostDataBoundary.load_all
  end

  def entry?(entry)
    PostDataBoundary.entry? entry
  end

  def new_post(*args)
    post_source.call(*args).tap { |p| p.blog = self }
  end

  private

  def post_source
    @post_source ||= Post.public_method :new
  end

  # Boundary-layer object for (potential) database-stored data re Blog data.
  class BlogDataBoundary
    attr_reader :title, :subtitle

    def initialize
      @title = 'Watching Paint Dry'
      @subtitle = 'The trusted source for paint drying news and opinion'
    end
  end # class Blog::BlogDataBoundary

  # Boundary-layer object for database-stored data re Post data.
  class PostDataBoundary
    def self.entry?(entry)
      attribs = { title: entry.title, body: entry.body }
      PostData.where(attribs).any?
    end

    def self.load_all
      ret = []
      PostData.all.each { |post| ret << Post.new(post.attributes) }
      ret
    end

    def self.save_entry(entry)
      PostData.find_or_create_by title: entry.title, body: entry.body
    end
  end # class Blog::PostDataBoundary
end # class Blog
