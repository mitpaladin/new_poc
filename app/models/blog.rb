
include Forwardable

# Blog class encapsulates the blog as a whole.
class Blog
  extend Forwardable
  include Comparable
  def_delegators :@blog_data, :title, :subtitle
  attr_reader :entries
  attr_writer :post_source

  def initialize
    @blog_data = BLO::BlogDataBoundary.new
    @entries = []
  end

  def add_entry(entry)
    entry.instance_variable_set '@blog'.to_sym, self
    @entries << entry
  end

  def entry?(entry)
    @entries.include? entry
  end

  def new_post(*args)
    post_source.call(*args).tap { |p| p.blog = self }
  end

  def <=>(other)
    sym = '<=>'.to_sym
    steps = [
      -> () { title.send sym, other.title },
      -> () { subtitle.send sym, other.subtitle },
      -> () { entries.length.send sym, other.entries.length },
      -> () { compare_entries other.entries }
    ]
    ret = 0
    steps.each { |step| ret = step.call if ret == 0 }
    ret
  end

  private

  def compare_entries(other_entries)
    ret = 0
    entries.each_with_index do |item, index|
      ret = compare_single_entries item, other_entries[index]
      break unless ret == 0
    end
    ret
  end

  def compare_single_entries(entry1, entry2)
    sym = '<=>'.to_sym
    ret = entry1.title.send sym, entry2.title
    ret = entry1.body.send(sym, entry2.body) if ret == 0
    # FIXME: Image URL field? Better yet, implement #<=> on Post and kill this.
    ret
  end

  def post_source
    @post_source ||= Post.public_method :new
  end
end # class Blog
