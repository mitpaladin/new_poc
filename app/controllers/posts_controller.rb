
require 'create_post'
require 'edit_post'
require 'index_posts'
require 'new_post'
require 'show_post'
require 'update_post'

# PostsController: actions related to Posts within our "fancy" blog.
class PostsController < ApplicationController
  def index
    Actions::IndexPosts.new(current_user)
      .subscribe(self, prefix: :on_index).execute
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

  def on_create_success(payload)
    @post = payload.entity
    redirect_to root_path, flash: { success: 'Post added!' }
  end

  def on_create_failure(payload, failed_attributes)
    prohibit_guest_user_from_proceeding(payload.errors)
    attribs = failed_attributes.to_h.merge author_name: current_user.name
    @post = invalid_post_with_errors PostEntity.new(attribs), payload.errors
    render 'new'
  rescue RuntimeError => e
    redirect_to root_path, flash: { alert: e.message }
  end

  def on_edit_success(payload)
    @post = payload.entity
  end

  def on_edit_failure(payload)
    redirect_to posts_path, flash: { alert: payload.errors.first[:message] }
  end

  def on_index_success(payload)
    @posts = payload.entity
    @posts
  end

  def on_new_success(payload)
    @post = payload.entity
  end

  def invalid_post_with_errors(source_post, errors)
    errors.each do |error|
      source_post.errors.add error[:field].to_sym, error[:message]
    end
    source_post
  end

  def on_new_failure(payload, invalid_entity)
    # @logger ||= MainLogger.log('log/posts_controller.log')
    prohibit_guest_user_from_proceeding(payload.errors)
    @post = invalid_post_with_errors invalid_entity, payload.errors
    render 'new'
  rescue RuntimeError => e
    redirect_to root_path, flash: { alert: e.message }
  end

  def on_show_success(payload)
    @post = payload.entity
  end

  def on_show_failure(payload)
    redirect_to posts_path, flash: { alert: payload.errors.first[:message] }
  end

  def on_update_success(payload)
    @post = payload.entity
    message = "Post '#{@post.title}' successfully updated."
    redirect_to post_path(@post.slug), flash: { success: message }
  end

  def on_update_failure(payload)
    redirect_to posts_path, flash: { alert: payload.errors.first[:message] }
  end

  private

  def prohibit_guest_user_from_proceeding(errors)
    return unless guest_is_current_user?
    message = errors.first.values.join(' ').capitalize
    fail message
  end

  def guest_is_current_user?
    guest_user = UserRepository.new.guest_user.entity
    current_user.name == guest_user.name
  end
end # class PostsController
