
require_relative 'store_result'
require_relative 'error_factory'

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

    def all
      dao.all.map { |record| factory.create record }
    end

    def find_by_slug(slug)
      found_post = dao.where(slug: slug).first
      return successful_result(found_post) if found_post
      failed_result slug
    end

    private

    def failed_result(slug)
      errors = ActiveModel::Errors.new dao
      errors.add :base, "A record with 'slug'=#{slug} was not found."
      failed_result_with_errors errors
    end

    def failed_result_with_errors(errors)
      StoreResult.new entity: nil, success: false,
                      errors: ErrorFactory.create(errors)
    end

    def successful_result(record)
      StoreResult.new success: true, errors: [],
                      entity: factory.create(record)
    end
  end # class MelddRepository::RepositoryBase
end # module MelddRepository
