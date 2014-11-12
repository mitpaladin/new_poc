
require_relative 'profile_article_list_builder/user_post_selector'

# Builds a list of articles (with links and publication date) for a user.
class ProfileArticleListBuilder
  def initialize(user_name, h)
    @user_name, @h = user_name, h
  end

  def to_html
    @h.content_tag :ul, nil, { class: 'list-group' }, false do
      build_inner_content_item_markup
    end
  end

  private

  def build_inner_content_item_markup
    posts_for_user.map do |post|
      ProfilePostItemBuilder.new(@h, post).to_html
    end.join.html_safe
  end

  def posts_for_user
    UserPostSelector.new(@user_name).build_list
  end
end
