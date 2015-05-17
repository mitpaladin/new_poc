
require 'contracts'

require 'base_summariser'

# Old-style junk drawer of view-helper functions, etc.
module PostsHelper
  # Support class for #summarise_blog method; builds list of Posts.
  class PostsSummariser < BaseSummariser
    include Contracts

    Contract Proc => PostsSummariser
    def initialize(&block)
      @data_class = PostDao
      @count = 10
      @sorter = -> (data) { data.sort_by(&:pubdate) }
      @orderer = -> (data) { data.reverse }
      super
      self
    end

    # FIXME: Resolve ambiguity stemming from entities in specs.
    SUMMARISE_CONTRACT = ArrayOf[Or[PostDao, Entity::Post]]

    Contract SUMMARISE_CONTRACT => SUMMARISE_CONTRACT
    def summarise(posts)
      summarise_data posts
    end
  end # class PostsHelper::PostsSummariser
end # module PostsHelper
