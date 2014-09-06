
# A controller should assign resources and redirect flow. Full stop.
class BlogController < ApplicationController
  def index
    @blog = policy_scope(BlogData.first).decorate
    # authorize @blog
  end
end # class BlogController
