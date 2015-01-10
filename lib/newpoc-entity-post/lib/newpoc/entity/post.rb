
require 'newpoc/entity/post/version'
require 'newpoc/support/instance_variable_setter'

require 'active_attr'

module Newpoc
  module Entity
    # a Post is the domain entity for a blog-type post, with title, body, etc.
    class Post
      module SupportClasses
        # Simple and to the point.
        module TimestampBuilder
          # Provides uniform formatting for timestamps.
          def timestamp_for(the_time = Time.now)
            the_time.to_time.localtime.strftime timestamp_format
          end

          def timestamp_format
            '%a %b %e %Y at %R %Z (%z)'
          end
        end # module TimestampBuilder

        # #################################################################### #

        # Build article byline markup.
        class BylineBuilder
          extend TimestampBuilder
          extend Forwardable

          def_delegator :@entry, :h, :h

          def initialize(decorated_entry)
            @entry = decorated_entry
          end

          def to_html
            doc = Nokogiri::HTML::Document.new
            para = Nokogiri::XML::Element.new 'p', doc
            para << inner(doc)
            doc << para
            para.to_html
          end

          protected

          attr_reader :entry

          private

          def inner(doc)
            ret = Nokogiri::XML::Element.new 'time', doc
            ret[:pubdate] = 'pubdate'
            ret << innermost
          end

          def innermost
            if entry.draft?
              parts = ['Drafted', date_str(entry.updated_at)]
            else
              parts = ['Posted', entry.pubdate_str]
            end
            (parts + ['by', entry.author_name]).join ' '
          end

          def date_str(the_date)
            the_date.localtime.strftime '%a %b %e %Y at %R %Z (%z)'
          end
        end # class Newpoc::Entity::Post::SupportClasses::BylineBuilder

        # #################################################################### #

        # Build image-post body.
        class ImageBodyBuilder
          # Note that since Markdown has no specific support for the
          # :figure, :img, or :figcaption tags beyond being a superset of
          # HTML (valid HTML in a Markdown document should be processed
          # correctly), we're leaving the `#build` method as is here.
          def build(obj)
            doc = Nokogiri::HTML::Document.new
            figure = Nokogiri::XML::Element.new 'figure', doc

            img = Nokogiri::XML::Element.new 'img', doc
            img[:src] = obj.image_url
            figure << img

            figcaption = Nokogiri::XML::Element.new 'figcaption', doc
            figcaption << body_markup(obj.body)
            figure << figcaption
            figure.to_html
          end

          private

          def body_markup(markup)
            MarkdownHtmlConverter.new.to_html(markup)
            # markup
          end
        end # class Newpoc::Entity::Post::SupportClasses::ImageBodyBuilder

        # #################################################################### #

        # Build text post body.
        class TextBodyBuilder
          def build(obj)
            "\n#{obj.body}\n"
          end
        end # class Newpoc::Entity::Post::SupportClasses::TextBodyBuilder
      end # module Newpoc::Entity::Post::SupportClasses
      private_constant :SupportClasses

      # ###################################################################### #

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
        MarkdownHtmlConverter.new.to_html(fragment)
      end

      def must_have_body_or_title
        return if body.present? || image_url.present?
        errors.add :body, 'must be specified if image URL is omitted'
      end
    end # class Newpoc::Entity::Post
  end # module Newpoc::Entity
end # module Newpoc
