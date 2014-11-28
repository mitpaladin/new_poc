
module Actions
  # Wisper-based command object called by Posts controller #new action.
  class CreatePost
    # Filters incoming post_data parameter and makes an OpenStruct of it.
    class PostDataFilter
      attr_reader :draft_post

      def initialize(post_data)
        @data = post_data.to_h.symbolize_keys
        @draft_post = false
      end

      def filter
        attribs = copy_attributes
        @draft_post = check_draft_status
        OpenStruct.new attribs.to_h.reject { |_k, v| v.nil? }
      end

      private

      attr_reader :data

      def check_draft_status
        data[:post_status] == 'draft'
      end

      def copy_attributes
        ret = Struct.new(*post_attributes).new
        post_attributes.each do |attrib|
          ret[attrib] = data[attrib].to_s.strip if data[attrib].present?
        end
        ret
      end

      def post_attributes
        %w(author_name title body image_url slug created_at updated_at pubdate
           post_status).map(&:to_sym)
      end
    end # class PostDataFilter

    # Verifies that the current user is not the Guest User
    class CurrentUserValidator
      def initialize(current_user, overrides = {})
        @current_user = current_user
        @entity_class = overrides.fetch :entity_class, default_entity_class
        @guest_user_finder = overrides.fetch :guest_user_finder, find_guest_user
      end

      def validate
        entity = entity_class.new author_name: current_user.name
        guest_user = guest_user_finder.call
        return entity if current_user.name != guest_user.name
        entity.errors.add :author_name, 'not logged in as a registered user!'
        entity
      end

      private

      attr_reader :current_user, :entity_class, :guest_user_finder

      def default_entity_class
        PostEntity
      end

      def find_guest_user
        -> { UserRepository.new.guest_user.entity }
      end
    end # class CurrentUserValidator

    include Wisper::Publisher
    attr_reader :current_user, :draft_post, :post_data

    def initialize(current_user, post_data)
      @current_user = current_user
      @post_data = filter_post_data post_data
    end

    def execute
      @entity = CurrentUserValidator.new(current_user).validate
      validate_post_data
      @entity = package_data_as_entity
      result = add_to_repository @entity
      broadcast_success result
    rescue RuntimeError => bad_entity_json_error
      broadcast_failure_for_errors(bad_entity_json_error)
    end

    private

    def broadcast_failure_for_errors(bad_entity_json_error)
      bad_entity_json = bad_entity_json_error.message
      bad_entity = PostEntity.new JSON.parse(bad_entity_json).symbolize_keys
      bad_entity.valid? # is false; builds error messages again
      errors = JSON.parse(bad_entity.errors.to_json).symbolize_keys
      result = StoreResult.new success: false, entity: nil,
                               errors: NewErrorFactory.create(errors)
      broadcast_failure result
    end

    def broadcast_failure(payload)
      failed_attributes = PostDataFilter.new(post_data).filter
      broadcast :failure, payload, OpenStruct.new(failed_attributes)
    end

    def broadcast_success(payload)
      broadcast :success, payload
    end

    def add_to_repository(entity)
      result = PostRepository.new.add entity
      fail entity.to_json unless result.success?
      result
    end

    def filter_post_data(post_data)
      filter = PostDataFilter.new(post_data)
      ret = filter.filter
      @draft_post = filter.draft_post
      ret
    end

    def package_data_as_entity
      attrs = @entity.attributes.merge FancyOpenStruct.new(post_data.to_h)
      @entity = PostEntity.new attrs
      return @entity if @entity.valid?
      fail @entity.to_json
    end

    def validate_post_data
      attrs = @entity.attributes.merge post_data.to_h.symbolize_keys
      @entity = PostEntity.new attrs
      return if @entity.valid?
      fail @entity.to_json
    end
  end # class Actions::CreatePost
end # module Actions
