
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
          @data = FancyOpenStruct.new JSON.load(payload)
          @user = UserEntity.new @data[:attributes] if @data[:attributes]
          @payload = payload
        end

        def parse
          check_for_conflicting_name
          user
        end

        private

        def check_for_conflicting_name
          return unless user.valid?
          user.errors.add :name, conflicting_name_message
          self
        end

        def conflicting_name_message
          'is invalid: ' + data[:messages].first
        end

        attr_reader :controller, :data, :user
      end # class UsersController::Internals::CreateFailure::UserChecker

      private_constant :UserChecker
    end # module UsersController::Internals::CreateFailure
  end # module UsersController::Internals
end # class UsersController
