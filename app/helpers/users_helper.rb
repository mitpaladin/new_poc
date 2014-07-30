
require_relative 'users_helper/profile_post_item_builder'
require_relative 'users_helper/profile_article_list_builder'

# Old-style junk drawer of view-helper functions, etc.
module UsersHelper
  def profile_article_list(user_name)
    ProfileArticleListBuilder.new(user_name, self).to_html
  end
end # module UsersHelper
