
require 'blog_listing_builder'

# A controller should assign resources and redirect flow. Full stop.
class BlogController < ApplicationController
  def index
    @blog = DSO::BlogListingBuilder.run! blog: Blog.new
  end
end
