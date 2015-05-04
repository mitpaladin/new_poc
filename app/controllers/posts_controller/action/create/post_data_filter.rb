
require 'action_support/hasher'

# PostsController: actions related to Posts within our "fancy" blog.
class PostsController < ApplicationController
  # Isolating our Action classes within the controller they're associated with.
  module Action
    # Wisper-based command object called by Posts controller #create action.
    class Create
      # Filters incoming post_data parameter and makes an OpenStruct of it.
      class PostDataFilter
        attr_reader :draft_post

        def initialize(post_data)
          @data = ActionSupport::Hasher.convert post_data
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

        def post_attributes
          %w(author_name title body image_url slug created_at updated_at
             pubdate post_status).map(&:to_sym)
        end
      end # class PostsController::Action::Create::Internals::PostDataFilter
    end # class PostsController::Action::Create
  end
end # class PostsController
