
# Builds a list of articles (with links and publication date) for a user.
class ProfileArticleListBuilder
  # Builds list of articles by author that current user is allowed to see.
  class UserPostSelector
    def initialize(user_name)
      @user_name = user_name
    end

    def build_list
      PostRepository.new.all.select { |post| post.author_name == @user_name }
    end
  end # class ProfileArticleListBuilder::UserPostSelector
end # class ProfileArticleListBuilder
