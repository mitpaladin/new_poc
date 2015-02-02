
require 'newpoc/action/post/index'

require 'create_post'
require 'edit_post'
require 'new_post'
require 'show_post'
require 'update_post'

# PostsController: actions related to Posts within our "fancy" blog.
class PostsController < ApplicationController
  def index
    action = Newpoc::Action::Post::Index.new current_user, PostRepository.new
    action.subscribe(self, prefix: :on_index).execute
  end

  def new
    Actions::NewPost.new(current_user)
      .subscribe(self, prefix: :on_new).execute
  end

  def create
    Actions::CreatePost.new(current_user, params[:post_data])
      .subscribe(self, prefix: :on_create).execute
  end

  def edit
    Actions::EditPost.new(params['id'], current_user)
      .subscribe(self, prefix: :on_edit).execute
  end

  def show
    Actions::ShowPost.new(params[:id], current_user)
      .subscribe(self, prefix: :on_show).execute
  end

  def update
    Actions::UpdatePost.new(params[:id], params[:post_data], current_user)
      .subscribe(self, prefix: :on_update).execute
  end

  # Action responders must be public to receive Wisper notifications; see
  # https://github.com/krisleech/wisper/issues/75 for relevant detail. (Needless
  # to say that, even though these are public methods, they should never be
  # called directly.)

  def on_create_success(entity)
    @post = entity
    redirect_to root_path, flash: { success: 'Post added!' }
  end

  def on_create_failure(payload)
    message_or_entity = JSON.load payload.message
    fail message_or_entity if message_or_entity.is_a? String
    invalid_entity = Newpoc::Entity::Post.new message_or_entity.symbolize_keys
    invalid_entity.valid?   # sets up error messages
    @post = invalid_entity
    render 'new'
  rescue RuntimeError => e # not logged in as a registered user
    redirect_to root_path, flash: { alert: e.message }
  end

  def on_edit_success(payload) # rubocop:disable Style/TrivialAccessors
    @post = payload
  end

  def on_edit_failure(payload)
    redirect_to root_path, flash: { alert: payload }
  end

  def on_index_success(payload) # rubocop:disable Style/TrivialAccessors
    @posts = payload
  end

  def on_new_success(payload) # rubocop:disable Style/TrivialAccessors
    @post = payload
  end

  def on_new_failure(payload)
    # Only supported error is for the guest user
    redirect_to root_path, flash: { alert: payload }
  end

  def on_show_success(payload) # rubocop:disable Style/TrivialAccessors
    @post = payload
  end

  def on_show_failure(payload)
    redirect_to root_path, flash: { alert: payload }
  end

  def on_update_success(payload)
    @post = payload
    message = "Post '#{@post.title}' successfully updated."
    redirect_to post_path(@post.slug), flash: { success: message }
  end

  def on_update_failure(payload)
    data = JSON.parse payload
    redirect_to root_path, flash: { alert: data.join('<br/>') }
  end
end # class PostsController
