
# Builds the actual list item included in the list built by the
# ProfileArticleListBuilder class.
class ProfilePostItemBuilder
  def initialize(h, post)
    @h, @post = h, post
  end

  def to_html
    h.content_tag :li, nil, { class: 'list-group-item' }, false do
      h.concat build_link
    end
  end

  protected

  attr_reader :h, :post

  private

  def build_link
    h.content_tag :a, nil, { href: "/posts/#{post.slug}" }, false do
      h.concat link_text
    end
  end

  def link_text
    [
      ['"', '"'].join(post.title),
      'Published',
      post.pubdate.localtime.strftime('%c %Z')
    ].join ' '
  end
end
