
require 'action_support/data_object_failure'

# UsersController: actions related to Users within our "fancy" blog.
class UsersController < ApplicationController
  # Isolating our Action classes within the controller they're associate with.
  module Action
    # Wisper-based command object called by Users controller #new action.
    class Create
      # Internal code called (initially) exclusively from Create class.
      module Internals
        # Persist an entity's data to the underlying repository. Raise on error.
        class EntityPersister
          attr_reader :entity

          def initialize(attributes:, repository:)
            @attributes = attributes
            @repository = repository
          end

          def persist
            new_entity = user_entity_with_passwords
            result = repository.add new_entity
            @entity = result.entity
            return self if result.success?
            fail_adding_user_to_repo(new_entity)
          end

          private

          attr_reader :attributes, :repository

          def factory_class
            UserPasswordEntityFactory
          end

          def fail_adding_user_to_repo(new_entity)
            new_entity.valid? # nope; now error messages are built
            params = {
              attributes: attributes,
              messages: new_entity.errors.full_messages
            }
            ActionSupport::DataObjectFailure.new(params).fail
          end

          def user_entity_with_passwords
            password = attributes[:password]
            factory_class.create(attributes, password).tap do |entity|
              # We've already verified password and confirmation match
              entity.password = password
              entity.password_confirmation = password
            end
          end
        end # class UsersController::Action::Create::Internals::EntityPersister
      end
    end # class UsersController::Action::Create
  end
end # class UsersController
