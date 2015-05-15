
require 'contracts'

# Builds a list of articles (with links and publication date) for a user.
class ProfileArticleListBuilder
  # Builds list of articles by author that current user is allowed to see.
  class UserPostSelector
    include Contracts

    Contract String, RespondTo[:name] => UserPostSelector
    def initialize(user_name, current_user)
      @user_name = user_name
      @current_user = current_user
      self
    end

    Contract None => ArrayOf[RespondTo[:author_name, :published?]]
    def build_list
      PostRepository.new.all.select { |post| visible? post }
    end

    private

    attr_reader :current_user, :user_name

    Contract RespondTo[:author_name, :published?] => Bool
    def visible?(post)
      return false unless post.author_name == user_name
      post.published? || (post.author_name == current_user.name)
    end
  end # class ProfileArticleListBuilder::UserPostSelector
end # class ProfileArticleListBuilder
