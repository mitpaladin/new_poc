
# Module containing "boundary-layer objects" between DSOs and implementation.
module BLO
  # Boundary-layer object for (potential) database-stored data re Blog data.
  class BlogDataBoundary
    attr_reader :title, :subtitle

    # We need to get entries (posts) from *somewhere*; we're not handed in a
    # collection of Post instances (or PostData instances, for that matter).
    # We're being called from either a DSO or a CCO, so chances are very good
    # that our caller can deal with entities more readily than implementation
    # model instances. (BlogData doesn't know about PostData now, anyway.). So,
    # entities. But how to get them? The `PostDataBoundary` class' `#load_all`
    # method. Pffft.
    def initialize(impl = BlogData.first)
      @title = impl.title
      @subtitle = impl.subtitle
      self
    end

    def entries
      PostDataBoundary.load_all
    end
  end # class BLO::BlogDataBoundary
end # module BLO
