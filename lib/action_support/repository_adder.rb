
module ActionSupport
  # Adds a new record with specified attributes to a repository, using the
  # specified factory class to build an entity to pass to the repository.
  class RepositoryAdder
    attr_reader :entity

    def initialize(attributes:, factory_class:, repository:)
      @attributes = attributes
      @factory_class = factory_class
      @repository = repository
      @persister_class = EntityPersister
    end

    def add
      params = { attributes: attributes, repository: repository }
      result = persister_class.new(params).persist do |attribs|
        factory_class.create attribs
      end
      @entity = result.entity
      self
    end

    private

    attr_reader :attributes, :factory_class, :repository, :persister_class
  end
end # module ActionSupport
