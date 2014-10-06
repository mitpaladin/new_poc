
require 'permissive_post_creator'
require 'post_creator_and_publisher'

# PostsController: actions related to Posts within our "fancy" blog.
class PostsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :article_not_found

  def index
    @posts = policy_scope(PostData.all)
  end

  def new
    post = DSO::PermissivePostCreator.run!
    # The DSO hands back an entity; Rails needs to see an implementation model
    @post = CCO::PostCCO.from_entity post
    authorize @post
    @post
  end

  def create
    post_params = tweak_create_params params
    post_status = params['post_data']['post_status']
    post = DSO::PostCreatorAndPublisher.run! params: post_params,
                                             post_status: post_status
    @post = CCO::PostCCO.from_entity post
    @post.valid?
    authorize @post
    process_create_result
  end

  def edit
    # FIXME: DSO? Input validity check?
    post = PostData.find(params['id']).decorate
    authorize post
    @post = post
  end

  def show
    post = PostData.find params[:id]
    @post = PostDataDecorator.new(post)
    authorize @post
  end

  def update
    post = PostData.find params[:id]
    authorize post
    @post = post
    if @post.update_attributes select_updates
      message = "Article '#{@post.title}' successfully updated."
      redirect_to post_path(@post.slug), flash: { success: message }
    else
      render 'edit'
    end
  end

  private

  def article_not_found
    redirect_to root_url, not_found_redirect_params
  end

  def not_found_redirect_params
    slug = params[:id]
    { flash: { alert: %(There is no article with an ID of "#{slug}"!) } }
  end

  def process_create_result
    # NOTE: It Would Be Very Nice If this used MQs or etc. to be more direct.
    if @post.valid?
      @post.save!
      redirect_to(root_path, redirect_params)
    else
      render 'new'
    end
  end

  def redirect_params
    { flash: { success:  'Post added!' } }
  end

  def select_updates
    updates = {}
    [:body, :image_url].each do |field|
      updates[field] = params[:post_data][field]
    end
    updates
  end

  def tweak_create_params(params)
    user = CCO::UserCCO.to_entity(current_user)
    params[:post_data][:author_name] = user.name if user.registered?
    params
  end
end # class PostsController
