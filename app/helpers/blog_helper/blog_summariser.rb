
require 'base_summariser'

# Old-style junk drawer of view-helper functions, etc.
module BlogHelper
  # Support class for #summarise_blog method; builds list of Posts.
  class BlogSummariser < BaseSummariser
    def initialize(&block)
      @count = 10
      @sorter = -> (data) { data.sort_by(&:pubdate) }
      @orderer = -> (data) { data.reverse }
      super
    end

    def summarise(posts)
      summarise_data posts
    end
  end # class BlogHelper::BlogSummariser
end # module BlogHelper
