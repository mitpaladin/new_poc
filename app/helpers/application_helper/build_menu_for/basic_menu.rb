
# require 'contracts'

require_relative 'menu_for_details_selector'

module ApplicationHelper
  # Module containing `ApplicationHelper#build_menu_for` and support classes.
  module BuildMenuFor
    module BasicMenu
      include Contracts

      Contract ViewHelper, Or[:navbar, :sidebar] => RespondTo[:markup]
      def init_basic_menu(h, which)
        extend MenuForDetailsSelector.new.select(which)
        @h = h
        self
      end

      private

      attr_reader :h

      Contract Proc => String
      def build_container(&block)
        h.content_tag :ul, class: container_classes do
          build_item_for 'Home', href: h.root_path
          build_item_for 'All members', href: h.users_path
          build_separator_item
          instance_eval(&block)
        end
      end

      Contract String, Maybe[Hash] => String
      def build_item_for(text, attrs = {})
        item = h.content_tag :li do
          link = h.content_tag :a, attrs do
            text
          end
          h.concat link
        end
        h.concat item
      end

      Contract None => String
      def build_separator_item
        item = h.content_tag :li, separator_attrs do
          HTMLEntities.new.decode '&nbsp;'
        end
        h.concat item
      end
    end # module ApplicationHelper::BuildMenuFor::BasicMenu
  end
end
