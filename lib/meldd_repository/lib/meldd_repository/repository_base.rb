
require_relative 'store_result'

# MelddRepository: includes base Repository class wrapping database access.
module MelddRepository
  # Shared code for mediating between engine-bound DAO and Entity.
  class RepositoryBase
    attr_reader :dao, :factory

    def initialize(factory, dao)
      @factory, @dao = factory, dao
    end

    def add(entity)
      attribs = entity.attributes.reject { |k, _v| k == :errors }
      record = dao.new attribs
      record_saved = record.save
      return successful_result(record) if record_saved
      failed_result_with_errors record.errors
    end

    private

    def successful_result(record)
      StoreResult.new success: true, errors: [],
                      entity: factory.create(record)
    end
  end # class MelddRepository::RepositoryBase
end # module MelddRepository
