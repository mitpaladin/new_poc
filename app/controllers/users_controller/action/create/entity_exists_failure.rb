
require 'contracts'

# UsersController: actions related to Users within our "fancy" blog.
class UsersController < ApplicationController
  # Isolating our Action classes within the controller they're associate with.
  module Action
    # Wisper-based command object called by Users controller #new action.
    class Create
      # Error raised by NewEntityVerifier if slugged entity already exists.
      class EntityExistsFailure < ActionSupport::DataObjectFailure
        include Contracts

        INIT_CONTRACT_INPUTS = {
          slug: String,
          attributes: RespondTo[:to_hash]
        }

        Contract INIT_CONTRACT_INPUTS => EntityExistsFailure
        def initialize(slug:, attributes:)
          @slug = slug
          super messages: messages, attributes: attributes
          self
        end

        private

        Contract None => String
        def entity_already_exists_message
          "A record identified by slug '#{@slug}' already exists!"
        end

        Contract None => ArrayOf[String]
        def messages
          [entity_already_exists_message]
        end
      end # class UsersController::Action::Create::EntityExistsFailure
    end # class UsersController::Action::Create
  end
end # class UsersController
