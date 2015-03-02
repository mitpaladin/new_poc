
# UsersController: actions related to Users within our "fancy" blog.
class UsersController < ApplicationController
  module Action
    # Edit-user domain-logic setup verifies that a user is logged in.
    class Edit
      include ActionSupport::Broadcaster
      attr_reader :entity

      def initialize(slug:, current_user:, user_repository:)
        @slug = slug
        @current_user = current_user
        @user_repository = user_repository
      end

      def execute
        find_user_for_slug
        verify_current_user
        broadcast_success entity
      rescue RuntimeError => error
        error_obj = Yajl.load error.message, symbolize_keys: true
        broadcast_failure error_obj
      end

      private

      attr_reader :current_user, :slug, :user_repository

      def find_user_for_slug
        result = user_repository.find_by_slug slug
        @entity = result.entity
        return if result.success?
        error = { slug: slug.to_s }
        fail Yajl.dump(error)
      end

      def verify_current_user
        return if current_user.name == entity.name
        error_data = {
          not_user: entity.name,
          current: current_user.name
        }
        fail Yajl.dump(error_data)
      end
    end # class UsersController::Action::Edit
  end
end # class UsersController
