
require 'base_summariser'

# Old-style junk drawer of view-helper functions, etc.
module PostsHelper
  # Support class for #summarise_blog method; builds list of Posts.
  class PostsSummariser < BaseSummariser
    def initialize(&block)
      @count = 10
      @sorter = -> (data) { data.sort_by(&:pubdate) }
      @orderer = -> (data) { data.reverse }
      super
    end

    def summarise(posts)
      summarise_data posts
    end
  end # class PostsHelper::PostsSummariser
end # module PostsHelper
