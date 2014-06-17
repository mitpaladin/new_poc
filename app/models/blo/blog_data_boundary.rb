
# Module containing "boundary-layer objects" between DSOs and implementation.
module BLO
  # Boundary-layer object for (potential) database-stored data re Blog data.
  class BlogDataBoundary
    attr_reader :title, :subtitle

    def initialize(_params = {})
      @title = 'Watching Paint Dry'
      @subtitle = 'The trusted source for drying paint news and opinion'
    end
  end # class BLO::BlogDataBoundary
end # module BLO
