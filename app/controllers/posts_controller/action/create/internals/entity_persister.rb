
# PostsController: actions related to Posts within our "fancy" blog.
class PostsController < ApplicationController
  # Isolating our Action classes within the controller they're associate with.
  module Action
    # Wisper-based command object called by Posts controller #create action.
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
            new_entity = yield attributes
            result = repository.add new_entity
            @entity = result.entity
            return self if result.success?
            fail_adding_to_repo new_entity
          end

          private

          attr_reader :attributes, :factory_class, :repository

          def fail_adding_to_repo(new_entity)
            new_entity.valid? # nope; now error messages are built
            params = {
              attributes: attributes,
              messages: new_entity.errors.full_messages
            }
            DataObjectFailure.new(params).fail
          end
        end # class PostsController::Action::Create::Internals::EntityPersister
      end
    end # class PostsController::Action::Create
  end
end # class PostsController
