
require_relative 'users_helper/profile_post_item_builder'
require_relative 'users_helper/profile_article_list_builder'
require_relative 'users_helper/profile_articles_row_builder'

# Old-style junk drawer of view-helper functions, etc.
module UsersHelper
  def profile_article_list(user_name)
    ProfileArticleListBuilder.new(user_name, self).to_html
  end

  def profile_articles_row(user_name)
    ProfileArticlesRowBuilder.new(user_name, self).to_html
  end
end # module UsersHelper
