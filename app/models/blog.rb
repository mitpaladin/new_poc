
# Blog class encapsulates the blog as a whole.
class Blog
  attr_reader :title, :subtitle, :entries
  attr_writer :post_source

  def initialize
    @title = 'Watching Paint Dry'
    @subtitle = 'The trusted source for paint drying news and opinion'
    @entries = []
  end

  def add_entry(entry)
    @entries << entry
  end

  def new_post(*args)
    post_source.call(*args).tap { |p| p.blog = self }
  end

  private

  def post_source
    @post_source ||= Post.public_method :new
  end
end # class Blog
