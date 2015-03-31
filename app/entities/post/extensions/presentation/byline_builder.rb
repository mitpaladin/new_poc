
require 'timestamp_builder'

# Namespace containing all application-defined entities.
module Entity
  # The Post class encapsulates post-related domain logic of our "fancy" blog.
  # It delegates or defers implementation-specific details such as persistence,
  # user interface, etc.
  class Post
    # Presentation-ish methods used by current Post entity API.
    module Extensions
      # Presentation-oriented "decorator" methods and support.
      module Presentation
        # Presentation-ish byline-builder class for posts.
        class BylineBuilder
          extend Forwardable
          include TimestampBuilder

          def_delegator :@entry, :h, :h

          def initialize(entry)
            @entry = entry
          end

          def to_html
            doc = Nokogiri::HTML::Document.new
            para = Nokogiri::XML::Element.new 'p', doc
            para << inner(doc)
            doc << para
            para.to_html
          end

          private

          attr_reader :entry

          def draft?
            entry.pubdate.nil?
          end

          def inner(doc)
            ret = Nokogiri::XML::Element.new 'time', doc
            ret[:pubdate] = 'pubdate'
            ret << innermost
          end

          def innermost
            (innermost_parts + ['by', entry.author_name]).join ' '
          end

          def innermost_parts
            if draft?
              ['Drafted', data_str(entry.updated_at)]
            else
              ['Posted', pubdate_str]
            end
          end

          def data_str(data)
            timestamp_for data.localtime
            # data.localtime.strftime '%a %b %e %Y at %R %Z (%z)'
          end

          def pubdate_str
            return 'DRAFT' if draft?
            timestamp_for entry.pubdate
          end
        end # class Entity::Post::Extensions::Presentation::BylineBuilder
      end
    end
  end # class Entity::Post
end
