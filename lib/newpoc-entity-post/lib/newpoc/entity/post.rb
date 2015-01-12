
require 'newpoc/entity/post/version'
require 'newpoc/support/instance_variable_setter'
require 'newpoc/services/markdown_html_converter'

require 'active_attr'
require 'html/pipeline'
require 'nokogiri'

require_relative 'post/byline_builder'
require_relative 'post/image_body_builder'
require_relative 'post/text_body_builder'
require_relative 'post/timestamp_builder'

module Newpoc
  module Entity
    # a Post is the domain entity for a blog-type post, with title, body, etc.
    class Post
      # Internal support classes specific to Post entity go in SupportClasses.
      module SupportClasses
      end # module Newpoc::Entity::Post::SupportClasses
      private_constant :SupportClasses

      include ActiveAttr::BasicModel
      include ActiveAttr::Serialization

      validates :author_name, presence: true
      validates :title, presence: true
      validate :must_have_body_or_title
      validate :author_must_not_be_the_guest_user
      # Without access to the database, we can't *really* validate the author
      # name.

      def initialize(attribs)
        init_attrib_keys.each { |attrib| class_eval { attr_reader attrib } }
        Newpoc::Support::InstanceVariableSetter.new(self).set attribs
        @pubdate ||= Time.now if attribs[:post_status] == 'public'
      end

      def attributes
        instance_values.symbolize_keys
      end

      def build_body
        fragment = body_builder_class.new.build self
        convert_body fragment
      end

      def build_byline
        BylineBuilder.new(self).to_html
      end

      # callback used by InstanceVariableSetter
      def init_attrib_keys
        %w(author_name body image_url slug title pubdate created_at updated_at)
          .map(&:to_sym)
      end

      # we're using FriendlyID for slugs, so...
      def persisted?
        !slug.nil?
      end

      def pubdate_str
        return 'DRAFT' if draft?
        timestamp_for pubdate
      end

      def published?
        pubdate.present?
      end

      def draft?
        pubdate.nil?
      end

      def post_status
        published? ? 'public' : 'draft'
      end

      private

      def guest_user_name
        'Guest User'
      end

      def author_must_not_be_the_guest_user
        return unless author_name == guest_user_name
        errors.add :author_name, 'must be a registered user'
      end

      def body_builder_class
        if image_url.present?
          SupportClasses::ImageBodyBuilder
        else
          SupportClasses::TextBodyBuilder
        end
      end

      def convert_body(fragment)
        Newpoc::Services::MarkdownHtmlConverter.new.to_html(fragment)
      end

      def must_have_body_or_title
        return if body.present? || image_url.present?
        errors.add :body, 'must be specified if image URL is omitted'
      end
    end # class Newpoc::Entity::Post
  end # module Newpoc::Entity
end # module Newpoc
