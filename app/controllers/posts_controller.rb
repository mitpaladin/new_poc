
require 'newpoc/action/post/show'
require 'newpoc/action/post/update'

require_relative 'posts_controller/create_failure_setup'
require_relative 'posts_controller/error_message_builder'

require_relative 'posts_controller/action/create'
require_relative 'posts_controller/action/index'
require_relative 'posts_controller/action/new'

# PostsController: actions related to Posts within our "fancy" blog.
class PostsController < ApplicationController
  # Internal classes exclusively used by PostsController.
  module Internals
  end
  private_constant :Internals
  include Internals

  # Isolating our Action classes within the controller they're associated with.
  module Action
  end

  def index
    Action::Index.new(current_user: current_user,
                      post_repository: PostRepository.new)
      .subscribe(self, prefix: :on_index)
      .execute
  end

  def new
    Action::New.new(current_user: current_user, repository: UserRepository.new,
                    entity_class: Newpoc::Entity::Post)
      .subscribe(self, prefix: :on_new)
      .execute
  end

  def create
    Action::Create.new(current_user: current_user,
                       post_data: params[:post_data])
      .subscribe(self, prefix: :on_create)
      .execute
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

  def on_create_failure(payload)
    @post = CreateFailureSetup.new(payload).cleanup.entity
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
    redirect_to root_path, flash: { alert: alert }
  end
end # class PostsController
