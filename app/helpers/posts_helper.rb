
# for Decorations::Posts::HtmlBodyBuilder class.
require 'posts/html_body_builder'

# Old-style junk drawer of view-helper functions, etc.
module PostsHelper
  def new_post_form_attributes(_params = {})
    attribs = shared_post_form_attributes 'new_post'
    attribs[:url] = posts_path
    attribs[:as] = :post_data
    attribs
  end

  def edit_post_form_attributes(post)
    attribs = shared_post_form_attributes 'edit_post'
    # NOTE: `post_path(post) works Just Fine in RSpec helper specs, but fails in
    #       RSpec *feature* specs (no matching controller action with id=nil).
    #       If anyone can enlighten me on how to make such code fail in helper
    #       unit specs, *please* send a pull request.
    attribs[:url] = post_path(post.slug)
    attribs[:as] = :post_data
    attribs
  end

  def status_select_options(post)
    option_items = [%w(draft draft), %w(public public)]
    # `status` appears to be an existing ActiveRecord::Base field. :(
    current_status = post.draft? ? 'draft' : 'public'
    options_for_select option_items, current_status
  end

  def summarise_posts(count_in = 10)
    the_sorter = sorter_hack
    summ = PostsSummariser.new do |s|
      s.count = count_in
      sorter -> (data) { the_sorter.call data }
    end
    summ.summarise(@posts)
  end

  def build_body(post)
    Decorations::Posts::HtmlBodyBuilder.new.build post
  end

  private

  def shared_post_form_attributes(which)
    {
      html: {
        class:  ['form-horizontal', which].join(' '),
        id:     which
      },
      role:     'form'
    }
  end

  def sorter_hack
    lambda do |data|
      drafts = data.select(&:draft?).sort_by(&:updated_at)
      posts = data.select(&:published?).sort_by(&:pubdate)
      [posts, drafts].flatten
    end
  end
end
