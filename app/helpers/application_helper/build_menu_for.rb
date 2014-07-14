
module ApplicationHelper
  # Module containing the `#build_menu_for` application-helper method.
  module BuildMenuFor
    def build_menu_for(which)
      MenuForBuilder.new(self, which).to_html
    end

    private

    # Settings for MenuForBuilder to use when building a :navbar menu.
    module NavbarMenuForDetails
      def container_classes
        'nav navbar-nav'
      end

      def separator_attrs
        { style: 'min-width: 3rem;' }
      end
    end # module ApplilcationHelper::BuildMenuFor::NavbarMenuForDetails

    # Settings for MenuForBuilder to use when building a :sidebar menu
    module SidebarMenuForDetails
      def container_classes
        'nav nav-sidebar'
      end

      def separator_attrs
        {}
      end
    end # module ApplicationHelper::BuildMenuFor::SidebarMenuForDetails

    # Which settings module should be used for a MenuForBuilder instance?
    class MenuForDetailsSelector
      def select(which)
        if which == :navbar
          NavbarMenuForDetails
        elsif which == :sidebar
          SidebarMenuForDetails
        end # other value? Fall off; crash and burn; diagnose
      end
    end # class ApplicationHelper::BuildMenuFor::MenuForDetailsSelector

    # Class wrapping logic of `#build_menu_for` application-helper function.
    class MenuForBuilder
      include Rails.application.routes.url_helpers

      def initialize(h, which)
        extend MenuForDetailsSelector.new.select(which)
        @h = h
      end

      def to_html
        build_container do |cont|
          cont.build_item_for 'Home', href: root_path
          cont.build_item_for 'New Post', href: new_post_path
          cont.build_separator_item
          cont.build_item_for 'Sign up', href: new_user_path
          cont.build_item_for 'Log in', href: new_session_path
          cont.build_item_for 'Log out', cont.logout_params
        end
      end

      protected

      attr_reader :h

      def build_container
        h.content_tag :ul, class: container_classes do
          yield self
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

      def logout_params
        ret = {
          href: '/sessions/current',
          rel:  'nofollow'
        }
        ret['data-method'] = 'delete'
        ret
      end
    end # class MenuForBuilder
  end # module ApplicationHelper::BuildMenuFor
end # module ApplicationHelper
