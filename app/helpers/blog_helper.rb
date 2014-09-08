
# Old-style junk drawer of view-helper functions, etc.
module BlogHelper
  def summarise_blog(count = 10)
    PostData
        .all
        .map(&:decorate)
        .select(&:published?)
        .sort_by(&:pubdate)
        .reverse
        .take(count)
  end
end
