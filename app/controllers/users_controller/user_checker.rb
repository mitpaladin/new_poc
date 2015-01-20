
# Internal classes used by our UsersController.
class UsersController < ApplicationController
  # Contains internal modules/classes used by methods, e.g., #on_create_failure.
  module Internals
    # Contains internal modules/classes used by #on_create_failure.
    module CreateFailure
      # A #valid? user is invalid, because it's been kicked back to us with a
      # conflicting name.
      class UserChecker
        def initialize(payload, controller)
          @controller = controller
          @data = FancyOpenStruct.new YAML.load(payload)
          if @data[:attributes]
            @user = Newpoc::Entity::User.new @data[:attributes]
          end
          @payload = payload
        end

        def parse
          check_for_invalid_passwords
          check_for_conflicting_name
          check_for_other_name_issues
          user
        end

        private

        def check_for_invalid_passwords
          @filtered_msgs = data[:messages].grep(/Password/)
          return if filtered_msgs.empty?
          filtered_msgs.each do
            |msg| user.errors.add :password, padded_filtered_msgs(msg)
          end
        end

        def check_for_conflicting_name
          @filtered_msgs = data[:messages].grep(/already exists/)
          return if filtered_msgs.empty?
          filtered_msgs.each do
            |msg| user.errors.add :name, padded_filtered_msgs(msg)
          end
        end

        def check_for_other_name_issues
          @filtered_msgs = data[:messages].grep(/Name/)
          return if filtered_msgs.empty?
          filtered_msgs.each do
            |msg| user.errors.add :name, padded_filtered_msgs(msg)
          end
        end

        def padded_filtered_msgs(messg)
          'is invalid: ' + messg
        end

        attr_reader :controller, :data, :user, :filtered_msgs
      end # class UsersController::Internals::CreateFailure::UserChecker

      private_constant :UserChecker
    end # module UsersController::Internals::CreateFailure
  end # module UsersController::Internals
end # class UsersController
