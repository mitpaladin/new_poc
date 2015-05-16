
require 'contracts'

require_relative 'data_object_failure'

# Various support classes for controller-hosted action classes.
module ActionSupport
  # Persist an entity's data to the underlying repository. Raise on error.
  class EntityPersister
    include Contracts

    attr_reader :entity

    Contract Hashlike, RespondTo[:add, :find_by_slug] => EntityPersister
    def initialize(attributes:, repository:)
      @attributes = attributes
      @repository = repository
      self
    end

    Contract Proc => EntityPersister
    def persist
      new_entity = yield attributes
      result = repository.add new_entity
      @entity = result.entity
      return self if result.success?
      fail_adding_to_repo new_entity
    end

    private

    attr_reader :attributes, :repository

    Contract RespondTo[:valid?, :errors] => DataObjectFailure
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
