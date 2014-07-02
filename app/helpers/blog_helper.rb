
# Old-style junk drawer of view-helper functions, etc.
module BlogHelper
  def entries_for(blog = BlogData.first)
    BLO::BlogDataBoundary.new(blog).entries
  end
end
