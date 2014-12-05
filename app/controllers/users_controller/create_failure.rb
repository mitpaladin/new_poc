
# Internal classes used by our UsersController.
class UsersController < ApplicationController
  # Contains internal modules/classes used by methods, e.g., #on_create_failure.
  module Internals
    module CreateFailure
      # Redirects if we get a message but no attributes; a signal to bail out.
      class BlockingFailureRedirector
        def initialize(payload, controller)
          @controller = controller
          @data = FancyOpenStruct.new JSON.load(payload)
          @user = UserEntity.new @data[:attributes] if @data[:attributes]
        end

        def check
          return unless user.nil?
          alerts = data[:messages].join alert_separator
          controller.redirect_to target_path, flash: { alert: alerts }
          self
        end

        private

        def alert_separator
          '<br/>'
        end

        def target_path
          controller.root_path
        end

        attr_reader :controller, :data, :user
      end # class Internals::CreateFailure::BlockingFailureRedirector

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
      end # class Internals::CreateFailure::UserChecker
    end # module Internals::CreateFailure
    private_constant :CreateFailure
    include CreateFailure

    def user_for_create_failure(payload, controller)
      BlockingFailureRedirector.new(payload, controller).check
      @user = UserChecker.new(payload, controller).parse
    end
  end # module Internals
  private_constant :Internals
end # class ApplicationController
