
require_relative 'blog_helper/blog_summariser'

# Old-style junk drawer of view-helper functions, etc.
module BlogHelper
  def summarise_blog(count = 10)
    BlogSummariser.new do |s|
      s.count = count
      selector { |data| data }
      sorter do |data|
        drafts = data.reject(&:published?).sort_by(&:updated_at)
        posts = data.select(&:published?).sort_by(&:pubdate)
        [posts, drafts].flatten
      end
    end.summarise
  end
end # module BlogHelper
