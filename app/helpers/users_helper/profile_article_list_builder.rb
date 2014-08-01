
# Builds a list of articles (with links and publication date) for a user.
class ProfileArticleListBuilder
  def initialize(user_name, h)
    @user_name, @h = user_name, h
  end

  def to_html
    h.content_tag :ul, nil, { class: 'list-group' }, false do
      posts_for_user.map do |post|
        ProfilePostItemBuilder.new(h, post).to_html
      end.join.html_safe
    end
  end

  protected

  attr_reader :h, :user_name

  private

  def posts_for_user
    PostData.select { |post| post.author_name == user_name }.map(&:decorate)
  end
end
