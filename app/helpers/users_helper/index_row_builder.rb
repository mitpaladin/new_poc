
require 'timestamp_builder'

# Moved from its previous home in a Draper decorator. See Issue #119.
class IndexRowBuilder
  def initialize(post_count, current_user)
    @current_user = current_user
    @post_count = post_count
    @highlight_class = 'info'
    extend TimestampBuilder
  end

  def build(target_user)
    @target_user = target_user
    doc = Nokogiri::HTML::Document.new
    build_row(doc).tap do |row|
      row << build_name_item(doc)
      row << build_posts_item(doc)
      row << build_member_since_item(doc)
      # Nokogiri adds newlines to everything. 3 children suddenly become 7. :-(
    end.to_html.gsub("\n", '')
  end

  private

  attr_reader :current_user, :highlight_class, :post_count, :target_user

  def build_member_since_item(doc)
    Nokogiri::XML::Element.new('td', doc) do |elem|
      elem << timestamp_for(target_user.created_at)
    end
  end

  def build_name_item(doc)
    Nokogiri::XML::Element.new('td', doc).tap do |elem|
      elem << link_to(target_user.name, user_path_for(target_user), doc)
    end
  end

  def build_posts_item(doc)
    Nokogiri::XML::Element.new('td', doc).tap { |elem| elem << post_count.to_s }
  end

  def build_row(doc)
    Nokogiri::XML::Element.new('tr', doc).tap do |row|
      row[:class] = highlight_class if current_user_targeted
    end
  end

  def current_user_targeted
    current_user.name == target_user.name
  end

  def link_to(text, url, doc)
    Nokogiri::XML::Element.new('a', doc).tap do |elem|
      elem[:href] = url
      elem << text
    end
  end

  def user_path_for(user)
    '/users/' + user.slug
  end
end
