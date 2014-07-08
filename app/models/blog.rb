
include Forwardable

# Blog class encapsulates the blog as a whole.
class Blog
  extend Forwardable
  include Comparable
  include Enumerable
  def_delegators :@blog_data, :title, :subtitle, :entries
  attr_reader :entries
  attr_writer :post_source

  def initialize
    @blog_data = BLO::BlogDataBoundary.new
    @entries = []
  end

  def add_entry(entry)
    return @entries if @entries.include? entry

    entry.instance_variable_set '@blog'.to_sym, self
    @entries << entry
  end

  def each
    @entries.each { |entry| yield entry }
  end

  def entry?(entry)
    @entries.include? entry
  end

  def new_post(*args)
    post_source.call(*args).tap { |p| p.blog = self }
  end

  def <=>(other)
    comparator = -> (pair) { pair[0] <=> pair[1] }
    failures = field_pairs(other).reject { |p| comparator.call(p) == 0 }
    return 0 if failures.empty?
    comparator.call failures[0]
  end

  private

  def field_pairs(other)
    [
      [title, other.title],
      [subtitle, other.subtitle],
      [entries, other.entries]
    ]
  end

  def post_source
    @post_source ||= Post.public_method :new
  end
end # class Blog
