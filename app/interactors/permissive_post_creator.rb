
require 'blog_selector'
require_relative 'support/post_data_lambda'

module DSO
  # Create a new post on a blog, isolating the caller (which is normally the
  # controller) from any knowledge of exactly how that happens.
  class PermissivePostCreator < ActiveInteraction::Base
    hash :blog_params, default: {} do
      integer :id, default: 1
    end
    hash :post_data, default: {} do
      POST_DATA_LAMBDA.call self
    end

    def execute
      the_blog = BlogSelector.run! blog_params: blog_params
      the_blog.new_post post_data
    end
  end
end # module DSO
