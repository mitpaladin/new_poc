
require_relative 'users_helper/profile_post_item_builder'
require_relative 'users_helper/profile_article_list_builder'
require_relative 'users_helper/profile_articles_row_builder'
require_relative 'users_helper/profile_bio_header_builder'
require_relative 'users_helper/profile_bio_panel_builder'
require_relative 'users_helper/profile_bio_row_builder'
require 'index_row_builder'

# Old-style junk drawer of view-helper functions, etc.
module UsersHelper
  def build_index_row_for(user, post_count)
    IndexRowBuilder.new(post_count, controller.current_user).build user
  end

  def profile_article_list(user_name)
    ProfileArticleListBuilder.new(user_name, self).to_html
  end

  def profile_articles_row(user_name)
    ProfileArticlesRowBuilder.new(user_name, self).to_html
  end

  def profile_bio_header(user_name)
    ProfileBioHeaderBuilder.new(user_name, self).to_html
  end

  def profile_bio_panel(user_profile)
    ProfileBioPanelBuilder.new(user_profile, self).to_html
  end

  def profile_bio_row(user_name, user_profile)
    ProfileBioRowBuilder.new(user_name, user_profile, self).to_html
  end
end # module UsersHelper
