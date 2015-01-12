
require_relative 'timestamp_builder'

module Newpoc
  module Entity
    # a Post is the domain entity for a blog-type post, with title, body, etc.
    class Post
      module SupportClasses
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
            (innermost_parts + ['by', entry.author_name]).join ' '
          end

          def innermost_parts
            if entry.draft?
              ['Drafted', date_str(entry.updated_at)]
            else
              ['Posted', entry.pubdate_str]
            end
          end

          def date_str(the_date)
            the_date.localtime.strftime '%a %b %e %Y at %R %Z (%z)'
          end
        end # class Newpoc::Entity::Post::SupportClasses::BylineBuilder
      end # module Newpoc::Entity::Post::SupportClasses
    end # class Newpoc::Entity::Post
  end # module Newpoc::Entity
end # module Newpoc
