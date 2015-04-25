
# PostsController: actions related to Posts within our "fancy" blog.
class PostsController < ApplicationController
  # A Responder responds to the reported result of an application action in an
  # implementation-appropriate manner.
  module Responder
    # Takes a string serialising either an error message *or* the attributes of
    # an invalid DAO, passes the string to an error-message builder object, and
    # redirects to the root path using that error message for an alert flash.
    #
    # Makes use of these methods on the controller passed into `#initialize`:
    #
    # 1. `:current_user`;
    # 2. `:redirect_to`; and
    # 3. `:root_path`.
    #
    class UpdateFailure
      def initialize(controller)
        @redirect_to = controller.method :redirect_to
        @root_path = controller.method :root_path
        @current_user = controller.current_user
      end

      def respond_to(payload)
        @attribs = attributes_from_payload(payload)
        redirect_to.call root_path.call, flash: { alert: alert }
      end

      private

      attr_reader :attribs, :current_user, :redirect_to, :root_path

      def alert
        return guest_user_alert if guest_user?
        return other_author_alert unless current_user_is_author?
        invalid_data_alert
      end

      def attributes_from_payload(payload)
        payload_data = YAML.load(payload).deep_symbolize_keys
        return payload_data[:post] if payload_data.key? :post
        payload_data
      end

      def invalid_data_alert
        entity = PostFactory.create(attribs).tap(&:valid?)
        dao = PostRepository.new.dao.new attribs
        entity.errors.each { |attrib, msg| dao.errors.add attrib, msg }
        dao.errors.full_messages.first
      end

      def current_user_is_author?
        current_user.name == attribs[:author_name]
      end

      def guest_user?
        current_user.name == 'Guest User'
      end

      def guest_user_alert
        'Not logged in as a registered user!'
      end

      def other_author_alert
        "User #{current_user.name} is not the author of this post!"
      end
    end # class PostsController::Responder::UpdateFailure
  end
end # class PostsController
