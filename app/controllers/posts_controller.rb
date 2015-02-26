
require 'newpoc/action/post/index'
require 'newpoc/action/post/new'
require 'newpoc/action/post/show'
require 'newpoc/action/post/update'

require 'create_post'

require_relative 'posts_controller/error_message_builder'

require_relative 'posts_controller/action/create/internals/guest_user_access'

# PostsController: actions related to Posts within our "fancy" blog.
class PostsController < ApplicationController
  # Internal classes exclusively used by PostsController.
  module Internals
  end
  private_constant :Internals
  include Internals

  # Isolating our Action classes within the controller they're associate with.
  module Action
    # Wisper-based command object called by Posts controller #create action.
    class Create
      module Internals
        # Filters incoming post_data parameter and makes an OpenStruct of it.
        class PostDataFilter
          attr_reader :draft_post

          def initialize(post_data)
            @data = hash_input_data(post_data)
            @draft_post = false
          end

          def filter
            attribs = copy_attributes
            @draft_post = true if data_defines_draft?
            OpenStruct.new attribs.to_h.select { |_k, v| v }
          end

          private

          attr_reader :data

          def copy_attributes
            ret = Struct.new(*post_attributes).new
            post_attributes.each do |attrib|
              ret[attrib] = data[attrib].to_s.strip if data[attrib].present?
            end
            ret
          end

          def data_defines_draft?
            data[:post_status] == 'draft'
          end

          def hash_input_data(data)
            data.send(hasher_for(data)).symbolize_keys
          end

          def hasher_for(data)
            return :to_unsafe_h if data.respond_to? :to_unsafe_h
            :to_h
          end

          def post_attributes
            %w(author_name title body image_url slug created_at updated_at
               pubdate post_status).map(&:to_sym)
          end
        end # class Actions::Create::Internals::PostDataFilter
      end
      private_constant :Internals
      include Internals
      include Wisper::Publisher

      def initialize(current_user:, post_data:)
        filter = PostDataFilter.new(post_data)
        @post_data = filter.filter
        @draft_post = filter.draft_post
        @current_user = current_user
      end

      def execute
        prohibit_guest_access
        validate_post_data
        add_entity_to_repository
        broadcast_success @entity
      rescue RuntimeError => message_or_bad_entity
        broadcast_failure message_or_bad_entity
      end

      private

      attr_reader :current_user, :draft_post, :entity, :post_data

      def broadcast_failure(payload)
        broadcast :failure, payload
      end

      def broadcast_success(payload)
        broadcast :success, payload
      end

      def add_entity_to_repository
        result = PostRepository.new.add entity
        fail entity.to_json unless result.success?
        # DON'T just use the existing entity; it (shouldn't) have its slug set,
        # whereas the one that's been persisted and passed back through the
        # `StoreResult` does. (That's how `Entity::Post` determines whether it's
        # been persisted or not: whether the `slug` attribute is set.)
        @entity = result.entity
      end

      def prohibit_guest_access
        GuestUserAccess.new(current_user).prohibit
      end

      def validate_post_data
        attribs = post_data.to_h.symbolize_keys
        attribs[:author_name] ||= current_user.name
        @entity = Newpoc::Entity::Post.new attribs
        return if @entity.valid?
        fail @entity.to_json
      end
    end # class PostsController::Action::Create
  end

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
    redirect_to root_path, flash: { alert: alert }
  end
end # class PostsController
