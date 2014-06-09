
# A controller should assign resources and redirect flow. Full stop.
class BlogController < ApplicationController
  def index
    @blog = Blog.new
  end
end
