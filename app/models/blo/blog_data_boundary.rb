
# Module containing "boundary-layer objects" between DSOs and implementation.
module BLO
  # Boundary-layer object for (potential) database-stored data re Blog data.
  class BlogDataBoundary
    attr_reader :title, :subtitle

    def initialize(_params = {})
      data = BlogData.all.first
      @title = data.title
      @subtitle = data.subtitle
      self
    end
  end # class BLO::BlogDataBoundary
end # module BLO
