
# UsersController: actions related to Users within our "fancy" blog.
class UsersController < ApplicationController
  module Action
    # New-user controller-action encapsulation. Creates a new, empty entity.
    class New
      include ActionSupport::Broadcaster

      def initialize(current_user:, user_repo:)
        @current_user = current_user
        @user_repo = user_repo
      end

      def execute
        verify_not_logged_in
        broadcast_success success_payload
        self
      rescue RuntimeError
        broadcast_failure current_user
        self
      end

      private

      attr_reader :current_user, :user_repo

      def entity_class
        UserFactory.entity_class
      end

      def guest_user?
        guest_user = user_repo.guest_user.entity
        guest_user.name == current_user.name
      end

      def success_payload
        entity_class.new({})
      end

      def verify_not_logged_in
        fail current_user.name unless guest_user?
      end
    end # class UsersController::Action::New
  end
end # class UsersController
