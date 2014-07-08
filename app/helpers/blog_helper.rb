
require 'post_data_decorator'

# Old-style junk drawer of view-helper functions, etc.
module BlogHelper
  def entries_for(_blog = BlogData.first)
    PostData.all.decorate
    # ret = BLO::BlogDataBoundary.new(blog).entries
    # ret.each_with_index do |entry, index|
    #   ret[index] = PostDecorator.decorate entry
    # end
  end
end
