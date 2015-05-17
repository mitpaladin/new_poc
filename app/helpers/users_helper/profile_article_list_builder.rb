
require 'contracts'

require_relative 'profile_article_list_builder/user_post_selector'

# Builds a list of articles (with links and publication date) for a user.
class ProfileArticleListBuilder
  include Contracts

  USER_HELPER_INPUT_CONTRACT = RespondTo[:content_tag, :current_user]

  Contract String, USER_HELPER_INPUT_CONTRACT => ProfileArticleListBuilder
  def initialize(user_name, h)
    @user_name, @h = user_name, h
    self
  end

  Contract None => String
  def to_html
    @h.content_tag :ul, nil, { class: 'list-group' }, false do
      build_inner_content_item_markup
    end
  end

  private

  attr_reader :h

  Contract None => String
  def build_inner_content_item_markup
    posts_for_user.map do |post|
      ProfilePostItemBuilder.new(@h, post).to_html
    end.join.html_safe
  end

  Contract None => ArrayOf[RespondTo[:author_name, :published?]]
  def posts_for_user
    UserPostSelector.new(@user_name, h.current_user).build_list
  end
end
