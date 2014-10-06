
require_relative 'blog_helper/blog_summariser'

# Old-style junk drawer of view-helper functions, etc.
module BlogHelper
  def summarise_blog(count = 10)
    allowed_posts = data_policy_scope
    sorter = sorter_hack
    BlogSummariser.new do |s|
      s.count = count
      aggregator { allowed_posts }
      sorter { |data| sorter.call data }
    end.summarise
  end

  private

  def data_policy_scope
    Pundit.policy_scope! pundit_user, PostData.all
  end

  def sorter_hack
    lambda do |data|
      drafts = data.reject(&:published?).sort_by(&:updated_at)
      posts = data.select(&:published?).sort_by(&:pubdate)
      [posts, drafts].flatten
    end
  end
end # module BlogHelper
