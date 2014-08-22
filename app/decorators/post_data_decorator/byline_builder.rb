
require 'decorator_shared/timestamp_builder'

# PostDataDecorator: Draper Decorator, aka ViewModel, for the Post model.
class PostDataDecorator < Draper::Decorator
  # Build article byline markup. Called on behalf of
  # PostDataDecorator#build_byline.
  class BylineBuilder
    extend DecoratorShared

    def initialize(decorated_entry)
      @entry = decorated_entry
    end

    def to_html
      entry.h.content_tag :p do
        attribs = { pubdate: 'pubdate' }
        inner = entry.h.content_tag(:time, nil, attribs, false) do
          entry.h.concat build_innermost_line
        end
        entry.h.concat inner
      end
    end

    protected

    attr_reader :entry

    private

    def build_innermost_line
      ['Posted', build_pubdate, 'by', entry.author_name].join ' '
    end

    def build_pubdate
      UserDataDecorator.timestamp_for entry.pubdate
    end
  end
end # class PostDataDecorator
