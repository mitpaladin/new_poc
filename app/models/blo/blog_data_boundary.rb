
# Module containing "boundary-layer objects" between DSOs and implementation.
module BLO
  # Boundary-layer object for (potential) database-stored data re Blog data.
  class BlogDataBoundary
    attr_reader :title, :subtitle

    def initialize
      @title = 'Watching Paint Dry'
      @subtitle = 'The trusted source for paint drying news and opinion'
    end
  end # class BLO::BlogDataBoundary
end # module BLO
