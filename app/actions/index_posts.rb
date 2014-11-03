
module Actions
  # Wisper-based command object called by Posts controller #index action.
  class IndexPosts
    include Wisper::Publisher

    def initialize(current_user)
      @current_user = current_user
    end

    def execute
      posts = filter_posts PostRepository.new.all
      result = StoreResult.new success: true, errors: [], entity: posts
      broadcast_success result
    end

    private

    attr_reader :current_user

    def broadcast_success(payload)
      broadcast :success, payload
    end

    def filter_posts(all_posts)
      all_posts.select do |post|
        published?(post) || author?(current_user, post)
      end
    end

    def author?(user, post)
      post.author_name == user.name
    end

    def published?(post)
      post.pubdate.present?
    end
  end # class Actions::IndexPosts
end # module Actions
