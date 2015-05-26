
require 'contracts'

require 'timestamp_builder'
require_relative 'ox_builder'

# Moved from its previous home in a Draper decorator. See Issue #119.
class IndexRowBuilder
  class Builder < OxBuilder
    include Contracts

    ElementType = Ox::Element

    Contract UserInstance, UserInstance, Fixnum, Proc => Builder
    def initialize(target_user, current_user, post_count, &block)
      super()
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
      dump.gsub("\n", '')
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
  end # class IndexRowBuilder::Builder
end # class IndexRowBuilder
