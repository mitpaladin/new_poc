
# Builds a list of articles (with links and publication date) for a user.
class ProfileArticleListBuilder
  # Builds list of articles by author that current user is allowed to see.
  class UserPostSelector
    def initialize(user_name, h)
      @user_name, @h = user_name, h
    end

    def build_list
      posts = select_posts_by_user
      authorise_all(posts).reject(&:nil?)
    end

    private

    def authorise_all(posts)
      ret = []
      posts.each { |post| ret << authorise(post) }
      ret
    end

    def authorise(post)
      @h.controller.authorize post
      post
    rescue Pundit::NotAuthorizedError
      # must be a draft; skip it
      nil
    end

    def select_posts_by_user
      PostData.select { |post| post.author_name == @user_name }.map(&:decorate)
    end
  end # class ProfileArticleListBuilder::UserPostSelector
end # class ProfileArticleListBuilder
