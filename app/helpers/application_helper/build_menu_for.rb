
require_relative 'build_menu_for/menu_for_details_selector'

module ApplicationHelper
  # Module containing the `#build_menu_for` application-helper method.
  module BuildMenuFor
    def build_menu_for(which, current_user)
      MenuForBuilder.new(self, which, current_user).markup
    end

    private

    # Class wrapping logic of `#build_menu_for` application-helper function.
    class MenuForBuilder
      include Rails.application.routes.url_helpers
      attr_reader :markup

      def initialize(h, which, current_user)
        extend MenuForDetailsSelector.new.select(which)
        @h = h
        @current_user = get_entity_for current_user
        @markup = if @current_user.guest_user?
                    build_html_for_guest_user
                  else
                    build_html_for_registered_user
                  end
      end

      protected

      attr_reader :h

      def build_container(&block)
        h.content_tag :ul, class: container_classes do
          instance_eval(&block)
        end
      end

      def build_html_for_guest_user
        build_container do
          build_item_for 'Home', href: root_path
          build_item_for 'All members', href: users_path
          build_separator_item
          build_item_for 'Sign up', href: new_user_path
          build_item_for 'Log in', href: new_session_path
        end
      end

      def build_html_for_registered_user
        build_container do
          build_item_for 'Home', href: root_path
          build_item_for 'All members', href: users_path
          build_separator_item
          build_item_for 'New Post', href: new_post_path
          build_separator_item
          build_item_for 'View your profile', href: user_profile_path
          build_separator_item
          build_item_for 'Log out', logout_params
        end
      end

      def build_item_for(text, attrs = {})
        item = h.content_tag :li do
          link = h.content_tag :a, attrs do
            text
          end
          h.concat link
        end
        h.concat item
      end

      def build_separator_item
        item = h.content_tag :li, separator_attrs do
          HTMLEntities.new.decode '&nbsp;'
        end
        h.concat item
      end

      def get_entity_for(user)
        return user if user.respond_to? :guest_user?
        UserFactory.create user.attributes.symbolize_keys
      end

      def logout_params
        ret = {
          href: '/sessions/current',
          rel:  'nofollow'
        }
        ret['data-method'] = 'delete'
        ret
      end

      def user_profile_path
        user_path(id: @current_user.name.parameterize)
      end
    end # class MenuForBuilder
  end # module ApplicationHelper::BuildMenuFor
end # module ApplicationHelper
