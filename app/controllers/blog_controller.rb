
require 'blog_listing_builder'
require 'placeholder_builder'

# A controller should assign resources and redirect flow. Full stop.
class BlogController < ApplicationController
  def index
    datum = BlogData.first
    blog = CCO::BlogCCO.to_entity datum
    @blog = DSO::BlogListingBuilder.run! blog: blog
  end
end
