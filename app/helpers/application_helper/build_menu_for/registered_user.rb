
# require 'contracts'

require_relative 'menu_for_details_selector'

module ApplicationHelper
  # Module containing `ApplicationHelper#build_menu_for` and support classes.
  module BuildMenuFor
    class RegisteredUser
      include Contracts

      Contract ViewHelper, Or[:navbar, :sidebar],
               RespondTo[:name] => RegisteredUser
      def initialize(h, which, current_user)
        extend MenuForDetailsSelector.new.select(which)
        @h = h
        @current_user = current_user
        self
      end

      Contract None => String
      def markup
        build_container do
          build_item_for 'Home', href: h.root_path
          build_item_for 'All members', href: h.users_path
          build_separator_item
          build_item_for 'New Post', href: h.new_post_path
          build_separator_item
          build_item_for 'View your profile', href: user_profile_path
          build_separator_item
          build_item_for 'Log out', logout_params
        end
      end

      private

      attr_reader :current_user, :h

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

      Contract None => Hash
      def logout_params
        {
          href: '/sessions/current',
          rel:  'nofollow'
        }.tap { |h| h['data-method'] = 'delete' }
      end

      Contract None => String
      def user_profile_path
        h.user_path(id: current_user.name.parameterize)
      end
    end # class ApplicationHelper::BuildMenuFor::RegisteredUser
  end
end
