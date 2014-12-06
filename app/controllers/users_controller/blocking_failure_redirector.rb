
# Internal classes used by our UsersController.
class UsersController < ApplicationController
  # Contains internal modules/classes used by methods, e.g., #on_create_failure.
  module Internals
    # Contains internal modules/classes used by #on_create_failure.
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

      private_constant :BlockingFailureRedirector
    end # module UsersController::Internals::CreateFailure
  end # odule UsersController::Internals
end # class UsersController
