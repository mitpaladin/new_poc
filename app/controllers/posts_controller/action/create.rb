
require_relative 'create/internals/guest_user_access'

# PostsController: actions related to Posts within our "fancy" blog.
class PostsController < ApplicationController
  # Isolating our Action classes within the controller they're associated with.
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
end # class PostsController
