
require 'contracts'

require 'user'
require_relative 'build_menu_for/menu_for_details_selector'

module ApplicationHelper
  # Module containing the `#build_menu_for` application-helper method.
  module BuildMenuFor
    include Contracts
    include Contracts::Modules

    Contract Symbol, RespondTo[:name, :profile] => String
    def build_menu_for(which, current_user)
      MenuForBuilder.new(self, which, current_user).markup
    end

    # Class wrapping logic of `#build_menu_for` application-helper function.
    class MenuForBuilder
      include Contracts
      include Rails.application.routes.url_helpers
      attr_reader :markup

      Contract RespondTo[:content_tag], Symbol,
               RespondTo[:name, :profile] => MenuForBuilder
      def initialize(h, which, current_user)
        extend MenuForDetailsSelector.new.select(which)
        @h = h
        @current_user = get_entity_for current_user
        @markup = if @current_user.guest_user?
                    build_html_for_guest_user
                  else
                    build_html_for_registered_user
                  end
        self
      end

      protected

      attr_reader :h

      Contract Proc => String
      def build_container(&block)
        h.content_tag :ul, class: container_classes do
          instance_eval(&block)
        end
      end

      Contract None => String
      def build_html_for_guest_user
        build_container do
          build_item_for 'Home', href: root_path
          build_item_for 'All members', href: users_path
          build_separator_item
          build_item_for 'Sign up', href: new_user_path
          build_item_for 'Log in', href: new_session_path
        end
      end

      Contract None => String
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

      Contract RespondTo[:name, :profile] => Entity::User
      def get_entity_for(user)
        return user if user.respond_to? :guest_user?
        UserFactory.create user.attributes.symbolize_keys
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
        user_path(id: @current_user.name.parameterize)
      end
    end # class MenuForBuilder
    private_constant :MenuForBuilder
  end # module ApplicationHelper::BuildMenuFor
end # module ApplicationHelper
