
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

    include Wisper::Publisher

    def initialize(current_user, post_data)
      @current_user = current_user
      @post_data = filter_post_data post_data
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

    attr_reader :current_user, :draft_post, :post_data, :entity

    def broadcast_failure(payload)
      broadcast :failure, payload
    end

    def broadcast_success(payload)
      broadcast :success, payload
    end

    # Support methods

    # ... for #initialize

    def filter_post_data(post_data)
      filter = PostDataFilter.new(post_data)
      ret = filter.filter
      @draft_post = filter.draft_post
      ret
    end

    # ... for #execute

    def add_entity_to_repository
      result = PostRepository.new.add entity
      fail entity.to_json unless result.success?
      # DON'T just use the existing entity; it (shouldn't) have its slug set,
      # whereas the one that's been persisted and passed back through the
      # `StoreResult` does. (That's how `PostEntity` determines whether it's
      # been persisted or not: whether the `slug` attribute is set.)
      @entity = result.entity
    end

    def prohibit_guest_access
      guest_user = user_repo.guest_user.entity
      return unless guest_user.name == current_user.name
      fail guest_user_not_authorised_message
    end

    def validate_post_data
      attribs = post_data.to_h.symbolize_keys
      attribs[:author_name] ||= current_user.name
      @entity = PostEntity.new attribs
      return if @entity.valid?
      fail @entity.to_json
    end

    # ... for #prohibit_guest_access

    def guest_user_not_authorised_message
      'Not logged in as a registered user!'.to_json
    end

    def user_repo
      @user_repo ||= UserRepository.new
    end
  end # class Actions::CreatePost
end # module Actions
