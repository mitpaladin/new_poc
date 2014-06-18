
# Module containing "boundary-layer objects" between DSOs and implementation.
module BLO
  # Boundary-layer object for (potential) database-stored data re Blog data.
  class BlogDataBoundary
    attr_reader :title, :subtitle

    def initialize(params = {})
      data = get_blog_data_for params
      @title = data.title
      @subtitle = data.subtitle
      self
    end

    private

    def get_blog_data_for(params = {})
      default_id = BlogData.all.first.id
      default_params = { id: default_id }
      blog_params = params.fetch :blog_params, default_params
      BlogData.find blog_params[:id]
    end
  end # class BLO::BlogDataBoundary
end # module BLO
