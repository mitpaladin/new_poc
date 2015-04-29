
require_relative 'posts_controller/create_failure_setup'
require_relative 'posts_controller/error_message_builder'

require_relative 'posts_controller/action/create'
require_relative 'posts_controller/action/edit'
require_relative 'posts_controller/action/index'
require_relative 'posts_controller/action/new'
require_relative 'posts_controller/action/show'
require_relative 'posts_controller/action/update'

require_relative 'posts_controller/responder/create_success'
require_relative 'posts_controller/responder/update_failure'

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

  def_action(:index) do
    { current_user: current_user, post_repository: Repository::Post.new }
  end

  def_action(:new) do
    {
      current_user: current_user, repository: UserRepository.new,
      entity_class: PostFactory.entity_class
    }
  end

  def_action(:create) do
    { current_user: current_user, post_data: params[:post_data] }
  end

  def_action(:edit) do
    {
      slug: params[:id], current_user: current_user,
      repository: Repository::Post.new
    }
  end

  def_action(:show) do
    {
      current_user: current_user, repository: Repository::Post.new,
      target_slug: params[:id]
    }
  end

  def_action(:update) do
    {
      current_user: current_user, slug: params[:id],
      post_data: params[:post_data], repository: Repository::Post.new
    }
  end

  # Action responders must be public to receive Wisper notifications; see
  # https://github.com/krisleech/wisper/issues/75 for relevant detail. (Needless
  # to say that, even though these are public methods, they should never be
  # called directly.)

  def on_create_success(entity)
    Responder::CreateSuccess.new(self).respond_to entity
  end

  def on_create_failure(payload)
    Responder::CreateFailure.new(self).respond_to payload
  end

  def on_edit_success(payload)
    Responder::EditSuccess.new(self).respond_to payload
  end

  # Actual Edit and Update failure logic is identical.
  def on_edit_failure(payload)
    Responder::EditFailure.new(self).respond_to payload
  end

  def on_index_success(payload)
    Responder::IndexSuccess.new(self).respond_to payload
  end

  def on_new_success(payload)
    Responder::NewSuccess.new(self).respond_to payload
  end

  def on_new_failure(payload)
    Responder::NewFailure.new(self).respond_to payload
  end

  def on_show_success(payload)
    Responder::ShowSuccess.new(self).respond_to payload
  end

  def on_show_failure(payload)
    Responder::ShowFailure.new(self).respond_to payload
  end

  def on_update_success(payload)
    Responder::UpdateSuccess.new(self).respond_to payload
  end

  def on_update_failure(payload)
    Responder::UpdateFailure.new(self).respond_to payload
  end
end # class PostsController
