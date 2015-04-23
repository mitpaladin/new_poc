
require 'posts/html_body_builder'
require 'posts/byline_builder'

# Old-style junk drawer of view-helper functions, etc.
module PostDaoHelper
  def build_body
    Decorations::Posts::HtmlBodyBuilder.new.build self
  end

  def build_byline
    Decorations::Posts::BylineBuilder.build self
  end
end
