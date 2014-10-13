
# Shared code for mediating between engine-bound DAO and Entity for use cases.
class RepositoryBase
  def initialize(factory, dao)
    @factory, @dao = factory, dao
  end

  def add(entity)
    record = dao.new entity.attributes
    return successful_result(record) if record.save
    failed_result_with_errors record.errors
  end

  def all
    dao.all.map { |record| factory.create record }
  end

  def delete(slug)
    # We pass in a slug; the Repository (and Entity) don't know what an 'id'
    # is. The DAO, however, is ActiveRecord, and seems to need an ID
    record = dao.find_by_slug(slug)
    return failed_result(slug) unless record
    destroyed_record_count = dao.delete(record.id)
    # This should never happen; if we can see it, we should be able to delete it
    return failed_result(record.id) if destroyed_record_count.zero?
    successful_result
  end

  def find_by_slug(slug)
    found_post = dao.where(slug: slug).first
    return successful_result(found_post) if found_post
    failed_result slug
  end

  def update(entity)
    result = find_by_slug entity.slug
    return result unless result.success?

    record = dao.where(slug: entity.slug).first
    unless record.update_attributes(entity.attributes)
      return failed_result_with_errors record.errors
    end
    successful_result record
  end

  private

  attr_reader :dao, :factory

  def entity_if_record?(record)
    return nil unless record
    factory.create record
  end

  def failed_result_with_errors(errors)
    StoreResult.new entity: nil, success: false,
                    errors: ErrorFactory.create(errors)
  end

  def failed_result(slug)
    errors = ActiveModel::Errors.new dao
    errors.add :base, "A record with 'slug'=#{slug} was not found."
    failed_result_with_errors errors
  end

  def successful_result(record = nil)
    StoreResult.new success: true, errors: nil,
                    entity: entity_if_record?(record)
  end
end # class RepositoryBase
