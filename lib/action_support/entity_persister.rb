
require 'action_support/data_object_failure'

# Various support classes for controller-hosted action classes.
module ActionSupport
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

    attr_reader :attributes, :repository

    def fail_adding_to_repo(new_entity)
      new_entity.valid? # nope; now error messages are built
      params = {
        attributes: attributes,
        messages: new_entity.errors.full_messages
      }
      DataObjectFailure.new(params).fail
    end
  end # class ActionSupport::EntityPersister
end # module ActionSupport
