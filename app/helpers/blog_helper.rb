
require_relative 'blog_helper/blog_summariser'

# Old-style junk drawer of view-helper functions, etc.
module BlogHelper
  def summarise_blog(count = 10)
    allowed_posts = Pundit.policy_scope! pundit_user, PostData.all
    sorter = sorter_hack
    BlogSummariser.new do |s|
      s.count = count
      s.aggregator { allowed_posts }
      s.selector { |data| data }
      s.sorter { |data| sorter.call data }
    end.summarise
  end

  private

  def sorter_hack
    lambda do |data|
      drafts = data.reject(&:published?).sort_by(&:updated_at)
      posts = data.select(&:published?).sort_by(&:pubdate)
      [posts, drafts].flatten
    end
  end
end # module BlogHelper
