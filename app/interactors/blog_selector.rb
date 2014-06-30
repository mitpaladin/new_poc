
module DSO
  # Build list of information about a blog for presentation: title, subtitle,
  # entry data.
  class BlogSelector < ActiveInteraction::Base
    hash :params, default: {} do
      hash :blog_params, default: {} do
        integer :id, default: 1
      end
    end

    def execute
      Blog.new # id: blog_id_from(params)
    end

    private

    def blog_id_from(params)
      default_params = { id: 1 }
      blog_params = params.fetch :blog_params, default_params
      blog_params[:id]
    end
  end # class DSO::BlogSelector
end # module DSO
