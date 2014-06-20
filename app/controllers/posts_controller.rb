
require 'blog_selector'
require 'permissive_post_creator'
require 'post_publisher'

# PostsController: actions related to Posts within our "fancy" blog.
class PostsController < ApplicationController
  def new
    post = DSO::PermissivePostCreator.run! new_post_params
    # The DSO hands back an entity; Rails needs to see an implementation model
    @post = CCO::PostCCO.from_entity post
  end

  def create
    blog = CCO::BlogCCO.to_entity BlogData.find(params[:blog])
    @post = create_post_and(blog, params) do |post|
      DSO::PostPublisher.run! post: post
    end
    redirect_to root_path, redirect_params
  rescue ActiveInteraction::InvalidInteractionError
    render 'new'
  end

  private

  def create_post_and(blog, params, &_block)
    post = DSO::PermissivePostCreator.run! blog: blog, params_in: params
    yield post
    CCO::PostCCO.from_entity post
  end

  def new_post_params
    {
      blog:       DSO::BlogSelector.run!,
      params_in:  { blog_post: {} }
    }
  end

  def redirect_params
    {
      flash:  {
        success:  'Post added!'
      }
    }
  end
end # class Blog::PostsController
