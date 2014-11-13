
require 'timestamp_builder'

include Forwardable

# Formerly included in a Draper decorator, when we used those pervasively.
class PostEntity
  # Build article byline markup. Called on behalf of
  # PostDataDecorator#build_byline.
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
  end
end # class PostEntity
