
# A controller should assign resources and redirect flow. Full stop.
class BlogController < ApplicationController
  def index
    @blog = BlogData.first
    # @blog = CCO::BlogCCO.to_entity datum
  end
end
