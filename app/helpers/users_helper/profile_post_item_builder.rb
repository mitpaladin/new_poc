
require 'contracts'

# Builds the actual list item included in the list built by the
# ProfileArticleListBuilder class.
class ProfilePostItemBuilder
  include Contracts

  # FIXME: A few feature specs pass in helpers that Contracts cannot validate,
  #        although they *seem* to work. Very odd.
  FIXME_CONTRACT_INPUTS = Any, RespondTo[:pubdate_str, :slug]

  Contract Any, RespondTo[:pubdate_str, :slug] => ProfilePostItemBuilder
  def initialize(h, post)
    @h = h
    @post = post
    self
  end

  Contract None => String
  def to_html
    h.content_tag :li, nil, { class: 'list-group-item' }, false do
      h.concat build_link
    end
  end

  protected

  attr_reader :h, :post

  private

  Contract None => String
  def build_link
    h.content_tag :a, nil, { href: "/posts/#{post.slug}" }, false do
      h.concat link_text
    end
  end

  Contract None => String
  def link_text
    ["\"#{post.title}\"", 'Published', post.pubdate_str].join ' '
  end
end
