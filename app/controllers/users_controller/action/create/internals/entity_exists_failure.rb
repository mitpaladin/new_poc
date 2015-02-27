
require 'action_support/data_object_failure'

# UsersController: actions related to Users within our "fancy" blog.
class UsersController < ApplicationController
  # Isolating our Action classes within the controller they're associate with.
  module Action
    # Wisper-based command object called by Users controller #new action.
    class Create
      module Internals
        # Error raised by NewEntityVerifier if slugged entity already exists.
        class EntityExistsFailure < ActionSupport::DataObjectFailure
          def initialize(slug:, attributes:)
            @slug = slug
            super messages: messages, attributes: attributes
          end

          private

          def entity_already_exists_message
            "A record identified by slug '#{@slug}' already exists!"
          end

          def messages
            [entity_already_exists_message]
          end
        end # class UsersController::Action::...::Internals::EntityExistsFailure
      end
    end # class UsersController::Action::Create
  end
end # class UsersController
