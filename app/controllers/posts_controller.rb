
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
    publication = publish_entry(params)
    @post = CCO::PostCCO.from_entity publication.inputs[:post]
    if @post.valid? && publication.valid?
      redirect_to(root_path, redirect_params)
    else
      render 'new'
    end
  end

  private

  def new_post_params
    {
      blog:       DSO::BlogSelector.run!,
      params_in:  { post_data: {} }
    }
  end

  # FIXME: Shouldn't this be a DSO in its own right?
  def publish_entry(params)
    blog_params = params[:blog] || {}
    blog = DSO::BlogSelector.run! blog_params: blog_params
    post = DSO::PermissivePostCreator.run! blog: blog, params_in: params
    DSO::PostPublisher.run post: post
  end

  def redirect_params
    { flash: { success:  'Post added!' } }
  end
end # class Blog::PostsController
