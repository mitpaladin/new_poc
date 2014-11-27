
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
        %w(title body image_url slug created_at updated_at pubdate)
          .map(&:to_sym)
      end
    end

    # Builds error messages for post validation.
    class PostValidation
      def self.errors_for(post)
        ret = []
        unless post.body.present? || post.image_url.present?
          ret << _body_and_image_url_both_missing_error
        end
        ret << _missing_title_error unless post.title.present?
        ret
      end

      def self._body_and_image_url_both_missing_error
        {
          field: 'body',
          message: 'must be specified if no image URL is specified'
        }
      end

      def self._missing_title_error
        { field: 'title', message: 'must be present' }
      end
    end # class CreatePost::PostValidation

    include Wisper::Publisher
    attr_reader :current_user, :draft_post, :post_data

    def initialize(current_user, post_data)
      @current_user = current_user
      @post_data = filter_post_data post_data
      @errors = []
    end

    def execute
      validate_current_user
      validate_post_data
      entity = package_data_as_entity
      result = add_to_repository entity
      broadcast_success result
    rescue
      return broadcast_failure_for_errors
    end

    private

    def broadcast_failure_for_errors
      result = StoreResult.new success: false, entity: nil,
                               errors: @errors
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
      fail Marshal.dump(result.errors) unless result.success?
      result
    end

    def filter_post_data(post_data)
      filter = PostDataFilter.new(post_data)
      ret = filter.filter
      @draft_post = filter.draft_post
      ret
    end

    def package_data_as_entity
      data = FancyOpenStruct.new post_data.to_h
      data.author_name = current_user.name
      data.pubdate = Time.now unless draft_post
      PostEntity.new data.to_h
    end

    def post_attributes
      %w(title body image_url slug created_at updated_at pubdaate).map(&:to_sym)
    end

    def validate_current_user
      guest_user = UserRepository.new.guest_user.entity
      return if current_user.name != guest_user.name
      @errors += [
        { field: 'user', message: 'not logged in as a registered user!' }
      ]
      fail Marshal.dump(@errors) unless @errors.empty?
    end

    def validate_post_data
      @errors += PostValidation.errors_for post_data
      return if @errors.empty?
      fail Marshal.dump(@errors)
    end
  end # class Actions::CreatePost
end # module Actions
