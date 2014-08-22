
require 'decorator_shared/timestamp_builder'

include Forwardable

# PostDataDecorator: Draper Decorator, aka ViewModel, for the Post model.
class PostDataDecorator < Draper::Decorator
  # Build article byline markup. Called on behalf of
  # PostDataDecorator#build_byline.
  class BylineBuilder
    extend DecoratorShared
    extend Forwardable

    def_delegator :@entry, :h, :h

    def initialize(decorated_entry)
      @entry = decorated_entry
    end

    def to_html
      h.content_tag :p do
        attribs = { pubdate: 'pubdate' }
        inner = h.content_tag(:time, nil, attribs, false) do
          h.concat build_innermost_line
        end
        h.concat inner
      end
    end

    protected

    attr_reader :entry

    private

    def build_innermost_line
      ['Posted', entry.pubdate_str, 'by', entry.author_name].join ' '
    end
  end
end # class PostDataDecorator
