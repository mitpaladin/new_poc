
require 'blog_selector'   # only needed for #new_post_params
require 'permissive_post_creator'
require 'post_creator_and_publisher'

# PostsController: actions related to Posts within our "fancy" blog.
class PostsController < ApplicationController
  def new
    post = DSO::PermissivePostCreator.run!
    # The DSO hands back an entity; Rails needs to see an implementation model
    @post = CCO::PostCCO.from_entity post
  end

  def create
    post = DSO::PostCreatorAndPublisher.run! params: params
    @post = CCO::PostCCO.from_entity post
    # NOTE: It Would Be Very Nice If™ this used MQs or etc. to be more direct.
    if @post.valid?
      redirect_to(root_path, redirect_params)
    else
      render 'new'
    end
  end

  private

  def redirect_params
    { flash: { success:  'Post added!' } }
  end
end # class Blog::PostsController
