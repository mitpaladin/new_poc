
require 'wisper'
require 'yajl/json_gem'
# require 'cabin'

require 'newpoc/action/post/update/version'
require 'newpoc/action/post/update/guest_access_failure'
require 'newpoc/action/post/update/invalid_attributes_failure'
require 'newpoc/action/post/update/not_author_failure'
require 'newpoc/action/post/update/slug_not_found_failure'
require 'newpoc/action/post/update/post_data_filter'
require 'newpoc/action/post/update/update_failure'

module Newpoc
  module Action
    module Post
      # Verifies that the current user is permitted to update a specified post.
      class Update
        # Internal support classes for the Update class
        module Internals
        end
        private_constant :Internals
        include Internals
        include Wisper::Publisher

        # rubocop:disable Metrics/ParameterLists
        def initialize(slug, post_data, current_user, post_repository,
                       guest_user, options = {})
          @slug = slug
          @post_data = PostDataFilter.new(post_data).filter
          @current_user = current_user
          @post_repository = post_repository
          @guest_user = guest_user
          @success_event = options.fetch :success, :success
          @failure_event = options.fetch :failure, :failure
          # @logger = Cabin::Channel.new
          # @logger.level = :debug
          # @logger.subscribe Logger.new(STDOUT)
        end
        # rubocop:enable Metrics/ParameterLists

        def execute
          prohibit_guest_access
          validate_slug
          verify_user_is_author
          validate_updated_attributes
          update_entity
          broadcast_success entity
        rescue RuntimeError => the_error
          broadcast_failure the_error.message
        end

        private

        attr_reader :failure_event, :success_event
        attr_reader :current_user, :entity, :guest_user, :post_data,
                    :post_repository, :slug

        def broadcast_success(payload)
          broadcast success_event, payload
        end

        def broadcast_failure(payload)
          broadcast failure_event, payload
        end

        def prohibit_guest_access
          return unless guest_user.name == current_user.name
          fail GuestAccessFailure.new(self).to_json
        end

        def update_entity # rubocop:disable Metrics/AbcSize
          inputs = post_data.to_h.reject { |k, _v| k == :post_status }
          result = post_repository.update slug, inputs
          fail UpdateFailure.new(slug, inputs).to_json unless result.success?
          @entity = post_repository.find_by_slug(slug).entity
          self
        end

        def validate_updated_attributes # rubocop:disable Metrics/AbcSize
          result = post_repository.find_by_slug slug
          fail SlugNotFoundFailure.new(self).to_json unless result.success?
          attribs = result.entity.attributes.merge post_data
          entity = result.entity.class.new attribs
          unless entity.valid?
            fail InvalidAttributesFailure.new(attribs).to_json
          end
          @entity = entity
          self
        end

        def validate_slug
          result = post_repository.find_by_slug slug
          @entity = result.entity
          return if result.success?
          fail SlugNotFoundFailure.new(self).to_json
        end

        def verify_user_is_author
          return if current_user.name == entity.author_name
          fail NotAuthorFailure.new(current_user.name, entity).to_json
        end
      end # class Newpoc::Action::Post::Update
    end
  end
end
