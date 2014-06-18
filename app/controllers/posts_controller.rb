
require 'blog_selector'
require 'permissive_post_creator'

# PostsController: actions related to Posts within our "fancy" blog.
class PostsController < ApplicationController
  def new
    blog = DSO::BlogSelector.run!
    @post = DSO::PermissivePostCreator.run! new_post_params(blog)
  end

  private

  def new_post_params(blog)
    {
      blog: blog,
      params_in: { blog_post: {} }
    }
  end
end # class Blog::PostsController
