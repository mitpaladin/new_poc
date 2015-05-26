
require 'contracts'

require 'timestamp_builder'

# Moved from its previous home in a Draper decorator. See Issue #119.
class IndexRowBuilder
  # Temporary class to localise Nokogiri API usage.
  class NokogiriBuilder
    include Contracts

    Contract String, Maybe[Proc] => Nokogiri::XML::Element
    def element(name)
      ret = Nokogiri::XML::Element.new name, doc
      ret.tap { yield ret if block_given? }
    end

    Contract String, String => Nokogiri::XML::Element
    def link_to(text, url)
      element('a').tap do |elem|
        elem[:href] = url
        elem << text
      end
    end

    private

    Contract None => Nokogiri::HTML::Document
    def doc
      @doc ||= new_doc
    end

    Contract None => Nokogiri::HTML::Document
    def new_doc
      Nokogiri::HTML::Document.new
    end
  end # temporary class IndexRowBuilder::NokogiriBuilder

  class Builder < NokogiriBuilder
    include Contracts

    ElementType = Nokogiri::XML::Element

    Contract UserInstance, UserInstance, Fixnum, Proc => Builder
    def initialize(target_user, current_user, post_count, &block)
      @post_count = post_count
      @current_user = current_user
      @target_user = target_user
      @highlight_class = 'info'
      extend TimestampBuilder
      instance_eval(&block)
      self
    end

    Contract None => String
    def to_html
      doc.to_html.lines[1..-1].join.gsub("\n", '')
    end

    private

    attr_reader :current_user, :highlight_class, :post_count, :target_user

    Contract None => Bool
    def current_user_targeted?
      current_user.name == target_user.name
    end

    Contract None => ElementType
    def post_count_wrapper
      element('td') { |elem| elem << post_count.to_s }
    end

    Contract None => ElementType
    def timestamp_wrapper
      element('td') do |elem|
        elem << timestamp_for(target_user.created_at)
      end
    end

    Contract Maybe[Proc] => ElementType
    def row_for
      ret = element('tr') do |row|
        row[:class] = highlight_class if current_user_targeted?
      end
      ret.tap { yield ret if block_given? }
    end

    Contract None => ElementType
    def target_user_link
      path = user_path_for target_user
      element('td') { |elem| elem << link_to(target_user.name, path) }
    end

    Contract UserInstance => String
    def user_path_for(user)
      '/users/' + user.slug
    end
  end

  include Contracts

  Contract Fixnum, RespondTo[:name] => IndexRowBuilder
  def initialize(post_count, current_user)
    @current_user = current_user
    @post_count = post_count
    self
  end

  Contract UserInstance => String
  def build(target_user)
    builder = Builder.new(target_user, current_user, post_count) do
      doc << row_for do |row|
        row << target_user_link
        row << post_count_wrapper
        row << timestamp_wrapper
      end
    end
    builder.to_html
  end

  private

  attr_reader :current_user, :post_count
end
