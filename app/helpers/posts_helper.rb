
require 'contracts'

# for Decorations::Posts::HtmlBodyBuilder class.
require 'posts/html_body_builder'
require 'posts/byline_builder'

# Old-style junk drawer of view-helper functions, etc.
module PostsHelper
  include Contracts

  Contract Maybe[RespondTo[:to_hash]] => HashOf[Symbol, Any]
  def new_post_form_attributes(_params = {})
    attribs = shared_post_form_attributes 'new_post'
    attribs[:url] = posts_path
    attribs[:as] = :post_data
    attribs
  end

  Contract RespondTo[:slug] => Hash
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

  Contract RespondTo[:draft?] => String
  def status_select_options(post)
    option_items = [%w(draft draft), %w(public public)]
    # `status` appears to be an existing ActiveRecord::Base field. :(
    current_status = post.draft? ? 'draft' : 'public'
    options_for_select option_items, current_status
  end

  Contract Fixnum => ArrayOf[RespondTo[:author_name, :title]]
  def summarise_posts(count_in = 10)
    the_sorter = sorter_hack
    summ = PostsSummariser.new do |s|
      s.count = count_in
      sorter -> (data) { the_sorter.call data }
    end
    summ.summarise(@posts)
  end

  private

  Contract String => Hash
  def shared_post_form_attributes(which)
    {
      html: {
        class:  ['form-horizontal', which].join(' '),
        id:     which
      },
      role:     'form'
    }
  end

  Contract None => Proc
  def sorter_hack
    lambda do |data|
      drafts = data.select(&:draft?).sort_by do |post|
        sort_by_timestamp post, [:updated_at, :created_at]
      end
      posts = data.select(&:published?).sort_by do |post|
        sort_by_timestamp post, [:pubdate]
      end
      [posts, drafts].flatten
    end
  end

  SBT_CONTRACT_RETURN = [Symbol, ActiveSupport::TimeWithZone]

  Contract RespondTo[:attributes], ArrayOf[Symbol] => SBT_CONTRACT_RETURN
  def sort_by_timestamp(post, fields)
    selectors = post.attributes.to_hash.select { |k, _v| fields.include? k }
    return [:current, Time.zone.now] if selectors.empty?
    selectors.first
  end
end
