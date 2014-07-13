
module ApplicationHelper
  # Module containing the `#build_menu_for` application-helper method.
  module BuildMenuFor
    def build_menu_for(which)
      MenuForBuilder.new(self, which).to_html
    end

    private

    # Class wrapping logic of `#build_menu_for` application-helper function.
    class MenuForBuilder
      def initialize(h, which)
        @h, @which = h, which
      end

      def to_html
        build_container do |cont|
          cont.build_item_for 'Home', href: h.root_path
          cont.build_item_for 'New Post', href: h.new_post_path
          cont.build_separator_item(which)
          cont.build_item_for 'Sign up', href: h.new_user_path
          cont.build_item_for 'Log in', href: h.new_session_path
          cont.build_item_for 'Log out', cont.logout_params
        end
      end

      protected

      attr_reader :h, :which

      def build_container
        h.content_tag :ul, class: container_classes do
          yield self
        end
      end

      def build_dummy_item
        build_item_for 'Dummy Text', href: '#'
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

      def build_separator_item(which)
        item = h.content_tag :li, style: separator_style(which) do
          h.concat '&nbsp;'
        end
        h.concat item
      end

      def container_classes
        parts = ['nav']
        parts << if which == :navbar
                   'navbar-nav'
                 elsif which == :sidebar
                   'nav-sidebar'
                 end
        parts.join ' '
      end

      def logout_params
        ret = {
          href: '/sessions/current',
          rel:  'nofollow'
        }
        ret['data-method'] = 'delete'
        ret
      end

      def separator_style(_which)
        'min-width: 3rem;'
      end
    end # class MenuForBuilder
  end # module ApplicationHelper::BuildMenuFor
end # module ApplicationHelper
