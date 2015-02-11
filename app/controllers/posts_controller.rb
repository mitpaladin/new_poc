
require 'newpoc/action/post/index'
require 'newpoc/action/post/new'
require 'newpoc/action/post/show'
require 'newpoc/action/post/update'

require 'create_post'

# PostsController: actions related to Posts within our "fancy" blog.
class PostsController < ApplicationController
  module Internals
    # Build alert message for failed 'edit' or 'update' action.
    class ErrorMessageBuilder
      def initialize(payload)
        @error_data = Yajl.load payload, symbolize_keys: true
      end

      def to_s
        if @error_data.key? :guest_access_prohibited
          'Not logged in as a registered user!'
        elsif @error_data.key? :created_at
          entity = Newpoc::Entity::Post.new @error_data
          entity.valid?
          entity.errors.full_messages.first
        else
          bad_author = @error_data[:current_user_name]
          "User #{bad_author} is not the author of this post!"
        end
      end
    end # class PostsController::Internals::ErrorMessageBuilder
  end # module PostsController::Internals
  private_constant :Internals
  include Internals

  def index
    action = Newpoc::Action::Post::Index.new current_user, PostRepository.new
    action.subscribe(self, prefix: :on_index).execute
  end

  def new
    action = Newpoc::Action::Post::New.new current_user, UserRepository.new,
                                           Newpoc::Entity::Post
    action.subscribe(self, prefix: :on_new).execute
  end

  def create
    Actions::CreatePost.new(current_user, params[:post_data])
      .subscribe(self, prefix: :on_create).execute
  end

  def edit
    action = Newpoc::Action::Post::Edit.new params[:id], current_user,
                                            PostRepository.new,
                                            UserRepository.new.guest_user.entity
    action.subscribe(self, prefix: :on_edit).execute
  end

  def show
    action = Newpoc::Action::Post::Show.new params[:id], current_user,
                                            PostRepository.new
    action.subscribe(self, prefix: :on_show).execute
  end

  def update
    guest_user = UserRepository.new.guest_user.entity
    action = Newpoc::Action::Post::Update.new params[:id], params[:post_data],
                                              current_user, PostRepository.new,
                                              guest_user
    action.subscribe(self, prefix: :on_update).execute
  end

  # Action responders must be public to receive Wisper notifications; see
  # https://github.com/krisleech/wisper/issues/75 for relevant detail. (Needless
  # to say that, even though these are public methods, they should never be
  # called directly.)

  def on_create_success(entity)
    @post = entity
    redirect_to root_path, flash: { success: 'Post added!' }
  end

  # FIXME: Internals class to encapsulate logic?
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
    alert = ErrorMessageBuilder.new(payload).to_s
    redirect_to root_path, flash: { alert: alert }
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
    alert = "Cannot find post identified by slug: '#{payload}'!"
    redirect_to root_path, flash: { alert: alert }
  end

  def on_update_success(payload)
    @post = payload
    message = "Post '#{@post.title}' successfully updated."
    redirect_to post_path(@post.slug), flash: { success: message }
  end

  def on_update_failure(payload)
    alert = ErrorMessageBuilder.new(payload).to_s
    q = Newpoc::Entity::Post.new Yajl.load(payload, symbolize_keys: true)
    ap [:line_129, q.attributes, q.valid?, q.errors.full_messages, alert]
    redirect_to root_path, flash: { alert: alert }
  end
end # class PostsController
