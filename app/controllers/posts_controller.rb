
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

  def on_create_failure(payload)
    parts = []
    payload.errors.each do |error|
      parts << [error[:field].to_s.capitalize, error[:message]].join(' ')
    end
    alert = parts.join '<br/>'
    redirect_to posts_path, flash: { alert: alert }
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

  def on_new_failure(payload)
    redirect_to root_path, flash: { alert: payload.errors.first[:message] }
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

  def post_status_updated?
    params[:post_data].key? :post_status
  end

  def pubdate_for(post_data)
    return nil if post_data[:post_status] == 'draft'
    Time.now
  end

  def select_updates
    field_update_keys = %w(body image_url)
    post_data = params[:post_data]
    updates = {}
    updates[:pubdate] = pubdate_for(post_data) if post_status_updated?
    updates.merge! post_data.keep_if { |k, _v| field_update_keys.include? k }
  end
end # class PostsController
