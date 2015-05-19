
require 'contracts'

require_relative './profile_article_list_builder'

# Builds a Bootstrap-styled "row" with a header and list of articles.
class ProfileArticlesRowBuilder
  include Contracts

  Contract String, RespondTo[:concat, :content_tag] => ProfileArticlesRowBuilder
  def initialize(user_name, h)
    @user_name = user_name
    @h = h
    self
  end

  Contract None => String
  def to_html
    h.content_tag :div, nil, { class: 'row', id: 'contrib-row' }, false do
      header = h.content_tag(:h3) { "Articles Authored By #{user_name}" }
      h.concat header
      h.concat ProfileArticleListBuilder.new(user_name, h).to_html
    end
  end

  protected

  attr_accessor :h, :user_name
end # class ProfileArticlesRowBuilder
