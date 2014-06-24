
require 'blog_selector'   # only needed for #new_post_params
require 'permissive_post_creator'
require 'post_creator_and_publisher'

# PostsController: actions related to Posts within our "fancy" blog.
class PostsController < ApplicationController
  def new
    post = DSO::PermissivePostCreator.run! new_post_params
    # The DSO hands back an entity; Rails needs to see an implementation model
    @post = CCO::PostCCO.from_entity post
  end

  def create
    post = DSO::PostCreatorAndPublisher.run! params: params
    @post = CCO::PostCCO.from_entity post
    if @post.valid?
      redirect_to(root_path, redirect_params)
    else
      render 'new'
    end
  end

  private

  # FIXME: Update PermissivePostCreator to use this as default if no params
  def new_post_params
    {
      blog:       DSO::BlogSelector.run!,
      params_in:  { post_data: {} }
    }
  end

  def redirect_params
    { flash: { success:  'Post added!' } }
  end
end # class Blog::PostsController
