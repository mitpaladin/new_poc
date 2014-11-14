
module Actions
  # Wisper-based command object called by Posts controller #new action.
  class CreatePost
    include Wisper::Publisher
    attr_reader :current_user, :draft_post, :post_data

    def initialize(current_user, post_data)
      @current_user = current_user
      @post_data = filter_post_data post_data
    end

    # rubocop:disable Metrics/AbcSize
    def execute
      guest_user = user_repo.guest_user.entity
      return broadcast_auth_failure if current_user.name == guest_user.name
      return broadcast_content_failure unless valid_post_data?
      data = FancyOpenStruct.new post_data.to_h
      data.author_name = current_user.name
      data.pubdate = Time.now unless draft_post
      entity = PostEntity.new data.to_h
      result = PostRepository.new.add entity
      return broadcast_failure(result) unless result.success?
      broadcast_success result
    end
    # rubocop:enable Metrics/AbcSize

    private

    def broadcast_failure(payload)
      broadcast :failure, payload
    end

    def broadcast_success(payload)
      broadcast :success, payload
    end

    def broadcast_auth_failure
      broadcast_failure_for :user, 'Not logged in as a registered user!'
    end

    def broadcast_content_failure
      broadcast_failure_for :post, 'Post data must include all required fields'
    end

    def broadcast_failure_for(key, message)
      result = StoreResult.new success: false, entity: nil,
                               errors: build_errors_for(key, message)
      broadcast_failure result
    end

    def build_errors_for(key, message)
      [{ field: key.to_s, message: message }]
    end

    # rubocop:disable Metrics/AbcSize
    def filter_post_data(post_data)
      return {} unless post_data.respond_to? :to_h
      ret = Struct.new(*post_attributes).new
      data = post_data.symbolize_keys
      post_attributes.each do |attrib|
        ret[attrib] = data[attrib].to_s.strip if data[attrib].present?
      end
      @draft_post = data[:post_status] == 'draft'
      OpenStruct.new ret.to_h.reject { |_k, v| v.nil? }
    end
    # rubocop:enable Metrics/AbcSize

    def post_attributes
      %w(title body image_url slug created_at updated_at pubdaate).map(&:to_sym)
    end

    def user_repo
      @user_repo ||= UserRepository.new
    end

    def valid_post_data?
      (post_data.image_url.present? || post_data.body.present?) &&
        post_data.title.present?
    end
  end # class Actions::CreatePost
end # module Actions
