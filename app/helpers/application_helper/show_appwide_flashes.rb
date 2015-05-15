
require 'contracts'

# Shell for ApplicationHelper module. Used to reopen module.
module ApplicationHelper
  # Module containing `#show_appwide_flashes` method and support code
  # exclusively therefor.
  module AppwideFlashes
    include Contracts

    Contract ArrayOf
    def show_appwide_flashes(flashes)
      return '' if flashes.empty?
      AppFlashBuilder.new(self).build(flashes)
    end

    # Internal support class used by `ApplicationHelper#show_appwide_flashes`
    class AppFlashBuilder
      def initialize(h)
        @h = h
      end

      def build(flashes)
        flashes.to_hash.map do |level, message|
          build_entry_for level, message
        end.join
      end

      private

      attr_accessor :h

      def build_entry_for(level, message)
        outer_div_tag(classes_for_level level) do
          entry_contents_with message
        end
      end

      def class_for_level(level)
        return 'alert-danger' if level.to_s == 'alert'
        'alert-' + level.to_s
      end

      def classes_for_level(level)
        ['alert', class_for_level(level), 'alert-dismissable'].join ' '
      end

      def close_button
        close_button_tag { Nokogiri::HTML.fragment('&times;').to_s }
      end

      def close_button_tag
        h.content_tag('button', type: 'button', class: 'close',
                                'data-dismiss' => 'alert',
                                'aria-hidden' => 'true') do |tag|
          yield tag
        end
      end

      def entry_contents_with(message)
        close_button << message
      end

      def outer_div_tag(classes)
        h.content_tag :div, nil, { class: classes }, false do |tag|
          yield tag
        end
      end
    end # class AppFlashBuilder
    private_constant :AppFlashBuilder
  end # module ApplicationHelper::AppwideFlashes
end # module ApplicationHelper
