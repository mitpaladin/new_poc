
# require 'contracts'

require_relative 'menu_for_details_selector'

module ApplicationHelper
  # Module containing `ApplicationHelper#build_menu_for` and support classes.
  module BuildMenuFor
    class GuestUser
      include Contracts

      Contract ViewHelper, Or[:navbar, :sidebar] => GuestUser
      def initialize(h, which)
        extend MenuForDetailsSelector.new.select(which)
        @h = h
        self
      end

      Contract None => String
      def markup
        build_container do
          build_item_for 'Home', href: h.root_path
          build_item_for 'All members', href: h.users_path
          build_separator_item
          build_item_for 'Sign up', href: h.new_user_path
          build_item_for 'Log in', href: h.new_session_path
        end
      end

      private

      attr_reader :h

      Contract Proc => String
      def build_container(&block)
        h.content_tag :ul, class: container_classes do
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
    end # class ApplicationHelper::BuildMenuFor::GuestUser
  end
end
