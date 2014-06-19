
require 'blog_selector'
require 'permissive_post_creator'

# PostsController: actions related to Posts within our "fancy" blog.
class PostsController < ApplicationController
  def new
    blog = DSO::BlogSelector.run!
    @post = DSO::PermissivePostCreator.run! new_post_params(blog)
  end

  def create
    #   @post = PermissivePostCreator.run! blog: @blog, params_in: params
    #   PostPublisher.run! post: @post
    #   redirect_to root_path, flash: { success: 'Post added!' }
    # rescue ActiveInteraction::InvalidInteractionError
    #   render 'new'
  end

  private

  def new_post_params(blog)
    {
      blog: blog,
      params_in: { blog_post: {} }
    }
  end
end # class Blog::PostsController
