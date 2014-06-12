
include Forwardable

# Blog class encapsulates the blog as a whole.
class Blog
  extend Forwardable
  def_delegators :@blog_data, :title, :subtitle
  attr_writer :post_source

  def initialize
    @blog_data = BLO::BlogDataBoundary.new
  end

  def add_entry(entry)
    BLO::PostDataBoundary.save_entry entry
  end

  def entries
    BLO::PostDataBoundary.load_all
  end

  def entry?(entry)
    BLO::PostDataBoundary.entry? entry
  end

  def new_post(*args)
    post_source.call(*args).tap { |p| p.blog = self }
  end

  private

  def post_source
    @post_source ||= Post.public_method :new
  end
end # class Blog
